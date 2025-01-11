#!/bin/bash
set -e


# Linux amd64
if [[ "$(uname)" == "Linux" ]] && [[ "$(arch)" == "x86_64" ]]; then
    vm_driver="kvm2"
    echo -e "You are on Linux with amd64 architecture, using ${vm_driver} driver\n"

    # Create the argo, dev and prod clusters
    minikube start --driver=${vm_driver} --addons=ingress -p argocd-cluster --network=argocd-workshop &> /dev/null &
    echo "(background process pid=$!) Creating argocd-cluster..."

    minikube start --driver=${vm_driver} --addons=ingress -p dev-cluster --network=argocd-workshop &> /dev/null &
    echo "(background process pid=$!) Creating dev-cluster..."

    minikube start --driver=${vm_driver} --addons=ingress -p prod-cluster --network=argocd-workshop &> /dev/null &
    echo -e "(background process pid=$!) Creating prod-cluster...\n"

    echo -e "Waiting for the cluster creation background processes to finish\n\n"
    wait

# macOS arm64
elif [[ "$(uname)" == "Darwin" ]] && [[ "$(uname -m)" == "arm64" ]]; then
    vm_driver="docker"
    echo -e "You are on macOS with arm64 architecture, using ${vm_driver} driver\n"

    # Create the argo, dev and prod clusters
    # The --listen-address and --apiserver-names are used to enable argocd to connect to the other clusters (docker containers) through the apiserver-name
    minikube start -p argocd-cluster --driver=${vm_driver} --addons=ingress --memory=2048M --cpus=2 --listen-address=0.0.0.0 --apiserver-names=argocd-workshop.com &> /dev/null &
    echo "(background process pid=$!) Creating argocd-cluster..."

    minikube start -p dev-cluster --driver=${vm_driver} --addons=ingress --memory=2048M --cpus=2 --listen-address=0.0.0.0 --apiserver-names=argocd-workshop.com &> /dev/null &
    echo "(background process pid=$!) Creating dev-cluster..."

    minikube start -p prod-cluster --driver=${vm_driver} --addons=ingress --memory=2048M --cpus=2 --listen-address=0.0.0.0 --apiserver-names=argocd-workshop.com &> /dev/null &
    echo -e "(background process pid=$!) Creating prod-cluster...\n"

    echo -e "Waiting for the cluster creation background processes to finish\n\n"
    wait

    # This logic is meant for allowing argocd to add other clusters that are also running as docker containers
    echo -e "[macOS] Changing the cluster servers in kubeconfig to argocd-workshop.com from 127.0.0.1"
    clusters=("argocd-cluster" "dev-cluster" "prod-cluster")
    for cluster in "${clusters[@]}"; do
        current_server=$(kubectl config view -o jsonpath="{.clusters[?(@.name=='$cluster')].cluster.server}")

        if [[ -n "${current_server}" ]]; then
            new_server="${current_server//127.0.0.1/argocd-workshop.com}"

            kubectl config set-cluster "${cluster}" --server="${new_server}"
            echo "Updated cluster '${cluster}' server URL to '${new_server}'"
        else
            echo "Cluster ${cluster} is not in the kubeconfig!"
            exit 1
        fi
    done
else
    echo -e "Unknown system or architecture.\n"
    exit 1;
fi

# Get back to the argocd-cluster context in kubectl
kubectl config use-context argocd-cluster

# Install ArgoCD in the argocd-cluster
echo -e "Creating 'argocd' namespace in the argocd-cluster...\n"
kubectl create namespace argocd --context argocd-cluster --dry-run=client -o yaml | kubectl apply -f -
echo -e "Installing ArgoCD in the argocd namespace...\n"
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml --context argocd-cluster

# Wait for up to 5 minutes until the argocd initial admin secret is present
echo -e "\nWait for the argocd initial admin secret to be present...\n"
kubectl wait -n argocd --for=create secret/argocd-initial-admin-secret --timeout=300s --context argocd-cluster

# Wait for up to 5 minutes until the argocd server secret is present
echo -e "\nWait for all the argocd pods to be ready...\n"
kubectl wait -n argocd pod --all --for=condition=ready --timeout=300s --context argocd-cluster

# Start kubectl port-forward in the background
echo -e "port forwarding the argocd-server to 127.0.0.1:9797 in the background\n"
kubectl port-forward service/argocd-server -n argocd 9797:443 --context argocd-cluster &
argo_port_forward_pid=$!

# Store the argocd initial admin password
argoURL="127.0.0.1:9797"
argoPassword=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" --context argocd-cluster | base64 -d)

# Login to argocd
argocd login --insecure ${argoURL} --username admin --password ${argoPassword}

# Add clusters to ArgoCD so that it can actually manage deployments in them
# Note that I am adding labels to these clusters for identification when using the ApplicationSet CR
echo "Adding dev-cluster and prod-cluster to argocd"

argocd cluster add --upsert dev-cluster --name dev-cluster --label environment=dev -y
argocd cluster add --upsert prod-cluster --name prod-cluster --label environment=prod -y

# Press Enter to interrupt the port forwarding background process
echo -e "\n\nPress Enter to stop port-forwarding..."
read

kill ${argo_port_forward_pid}
