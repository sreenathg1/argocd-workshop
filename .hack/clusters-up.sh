#!/bin/bash


# Linux amd64
if [[ "$(uname)" == "Linux" ]] && [[ "$(arch)" == "x86_64" ]]; then
    vm_driver="virtualbox"
    echo "You are on Linux with amd64 architecture, using ${vm_driver} driver\n\n"
# macOS arm64
elif [[ "$(uname)" == "Darwin" ]] && [[ "$(uname -m)" == "arm64" ]]; then
    vm_driver="parallels"
    echo "You are on macOS with arm64 architecture, using ${vm_driver} driver\n\n"
else
    echo "Unknown system or architecture.\n"
    exit 1;
fi

# Create the dev and prod clusters
minikube start --driver=docker -p argocd-cluster &> /dev/null &
echo "(background process pid=$!) Creating argocd-cluster..."

minikube start --driver=${vm_driver} -p dev-cluster &> /dev/null &
echo "(background process pid=$!) Creating dev-cluster..."

minikube start --driver=${vm_driver} -p prod-cluster &> /dev/null &
echo "(background process pid=$!) Creating prod-cluster...\n"

echo "Waiting for the background processes to finish\n\n"
wait

# Enable ingress addon to the clusters
echo "(background process pid=$!) Enabling ingress in argocd-cluster..."
minikube addons enable ingress -p argocd-cluster &> /dev/null &

echo "(background process pid=$!) Enabling ingress in dev-cluster..."
minikube addons enable ingress -p dev-cluster &> /dev/null &

echo "(background process pid=$!) Enabling ingress in prod-cluster...\n"
minikube addons enable ingress -p prod-cluster &> /dev/null &

echo "Waiting for the background processes to finish...\n\n"
wait

# Get back to the argocd-cluster context in kubectl
kubectl config use-context argocd-cluster

# Install ArgoCD in the argocd-cluster
echo "Installing ArgoCD in the argocd-cluster...\n"
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for up to 5 minutes until the argocd initial admin secret is present
echo "\nWait for the argocd initial admin secret to be present...\n"
kubectl wait -n argocd --for=create secret/argocd-initial-admin-secret --timeout=300s --context argocd-cluster

# Start kubectl port-forward in the background
echo "port forwarding the argocd-server to 127.0.0.1:9797 in the background\n"
kubectl port-forward service/argocd-server -n argocd 9797:443 &> /dev/null &
argo_port_forward_pid=$!

# Store the argocd initial admin password
argoURL="127.0.0.1:9797"
argoPassword=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

# Login to argocd
argocd login --insecure ${argoURL} --username admin --password ${argoPassword}

# Add clusters to ArgoCD so that it can actually manage deployments in them
# Note that I am adding labels to these clusters for identification when using the ApplicationSet CR
echo "Adding dev-cluster and prod-cluster to argocd"
argocd cluster add dev-cluster --name dev-cluster --label environment=dev -y
argocd cluster add prod-cluster --name prod-cluster --label environment=prod -y

# Press Enter to interrupt the port forwarding background process
echo "\n\nPress Enter to stop port-forwarding..."
read

kill ${argo_port_forward_pid}
