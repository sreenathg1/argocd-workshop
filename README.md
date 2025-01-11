<a name="readme-top"></a>

<!-- CONTACT ME -->
You can connect with me through LinkedIn using the link the following link: [![LinkedIn][linkedin-shield]][linkedin-url]

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-workshop">About The Workshop</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#setup">Setup</a></li>
      </ul>
    </li>
    <li>
      <a href="#argocd-applications-and-applicationsets-workshop">ArgoCD Applications and ApplicationSets Workshop</a>
      <ul>
        <li><a href="#argocd-application">ArgoCD Application</a></li>
        <li><a href="#argocd-applicationset">ArgoCD ApplicationSet</a></li>
      </ul>
    </li>
    <li>
      <a href="#argocd-app-of-apps-pattern-workshop">ArgoCD App of Apps Pattern Workshop</a>
      <ul>
        <li><a href="#multi-cluster-setup">Multi Cluster Setup</a></li>
        <li><a href="#app-of-apps">App of Apps</a></li>
        <li><a href="#app-of-appsets">App of AppSets</a></li>
      </ul>
    </li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>



<!-- ABOUT THE WORKSHOP -->
## About The Workshop

This is a workshop repository to walk-through ArgoCD. The motivation behind this project is to build a continuous deployment from the bottom up.

<p align="right">(<a href="#readme-top">back to top</a>)</p>



### Built With

* [![Python][Python]][Python-url]
* [![FastAPI][FastAPI]][FastAPI-url]
* [![Go][Go]][Go-url]
* [![Docker][Docker]][Docker-url]
* [![Kubernetes][Kubernetes]][Kubernetes-url]
* [![Github][Github]][Github-url]
* [![ArgoCD][ArgoCD]][ArgoCD-url]

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- GETTING STARTED -->
## Getting Started

Here are the sequential steps to get the workshop up and running!

### Prerequisites

1. Needed accounts:
    * Have a <a href="https://github.com/">GitHub</a> account

    * Have an account in a container registry platform. The ones tested for this workshop are <a href="https://www.docker.io/">Docker</a> and <a href="https://www.quay.io/">Quay</a>

2. Be familiar with:
    * The basics of <a href="https://kustomize.io/">kustomize</a>.

3. Required tools:
    * Kubectl CLI from your favorite package manager (brew, yum, apt, etc.)

    * ArgoCD CLI to try and get familiar with controlling the ArgoCD pipeline from the terminal. Use the instructions on the <a href="https://argo-cd.readthedocs.io/en/stable/cli_installation/">ArgoCD CLI Installation Page</a>. You can check if the installation was successful by running the following command in your shell and getting a response that looks like this
        >At the time of initiating the workshop workshop version 2.13.3 of ArgoCD CLI was used.

    * Minikube from the <a href="https://minikube.sigs.k8s.io/docs/start/">Minikube Official Installation Page</a>
        >At the time of initiating the workshop version 1.34.0 of Minikube was used.

    * <a href="https://minikube.sigs.k8s.io/docs/drivers/">An approperiate driver for your OS</a>. For this workshop we recommend <a href="https://docker.com/">Docker</a> for macOS and <a href="https://www.linux-kvm.org/">kvm2</a> for linux.

        * Install docker from the <a href="https://docker.com/">Docker Official Website</a> or using your preferred package manager.
            >At the time of initiating the workshop version 27.4.0 of Docker was used (`docker --version`).

        * Install <a href="https://www.linux-kvm.org/">kvm2</a> from the <a href="https://docs.fedoraproject.org/en-US/quick-docs/virtualization-getting-started/">fedora project virtualization docs</a>.
            >At the time of initiating the workshop version 10.1.0 of libvirtd was used (`libvirtd --version`).

### Setup

Setup your own forked repository, registry, and spin up a cluster with argocd.

>For the sake of simplicity we will do the forbidden: Commit and push the changes to master/main >:)

1. Github repository setup
    * Fork this repository to have your own copy which you could modify. This is important to be able to save your own repository secrets.

    * Enable read/write permissions for github workflows
        * Go to the forked repository Settings > Actions > General > Workflow Permissions and enable `Read and write permissions`

    * Make repo references point to your forked repo by using the `Own Fork` workflow
        * Navigate from the repository tab to Actions > Own Fork
        * Click on `Run workflow`, then again `Run workflow` (on the "master" branch)

2. Registry setup
    * Create your own public image repositories in your Quay/Docker registry named as follows:
        * fastapi-argocd-workshop
        * go-argocd-workshop

    * Create an access token in your registry account and store it into the forked repository secrets as `REGISTRY_ACCESS_TOKEN`.
        * To create a repository github actions secret navigate to your forked repository Settings > Secrets and Variables > Actions > Secrets > New repository secret.


    * Change the values of `REGISTRY_URL`, `REGISTRY_USERNAME`, `REGISTRY_ACCESS_USER` in the `argocd-workshop/.github/workflows/ci.yaml` file. For example:
        >Keep in mind that `REGISTRY_USERNAME` and `REGISTRY_ACCESS_USER` can be the same (in case of using docker forexample). while setting up a "robot" in quay will create a specific username for access to your image repos that will be different than your registry user.
        ```yaml
          # argocd-workshop/.github/workflows/ci.yaml

          # Quay example
          REGISTRY_URL: quay.io
          REGISTRY_USERNAME: falrayes
          REGISTRY_ACCESS_USER: falrayes+argocd_workshop

          # Docker example
          REGISTRY_URL: docker.io
          REGISTRY_USERNAME: falrayes
          REGISTRY_ACCESS_USER: falrayes
        ```

    * Build and push the first tags of the images to your registry using the `Deployment CI` workflow
        * Navigate from the repository tab to Actions > Deployment CI
        * Click on `Run workflow`, then again `Run workflow` (on the "master" branch)

3. ArgoCD Environment setup

    * Using Minikube with Docker/kvm2 as the driver and ingress addon enabled, start a Kubernetes cluster with 3 worker nodes running Kubernetes version 1.27.3 by running the following command.
       ```sh
       # linux
       ~$ minikube start --driver=kvm2 --addons=ingress -p argocd-cluster
       # or
       # macOS
       ~$ minikube start --driver=docker --addons=ingress -p argocd-cluster
       ```
       > This process might take some time if it is the first start up of minikube.

    * Install ArgoCD in the Kubernetes cluster by running the following commands.
       ```sh
       ~$ kubectl create namespace argocd
       ~$ kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
       ```
       >These commands are taken from <a href="https://argo-cd.readthedocs.io/en/stable/getting_started/">ArgoCD Installation Page</a>. Make sure that the official page takes priority over the commands in above.


    * Run one of the following commands to serve the ArgoCD service on your local machine in a different terminal instance.
        > You could run `kubectl wait -n argocd pod --all --for=condition=ready --timeout=300s --context argocd-cluster`
        > to make sure that all argocd pods are ready before port-forwarding.
        ```sh
        # You can choose a port of your choosing that is not in use. I will use 8181
        ~$ kubectl port-forward -n argocd svc/argocd-server 8181:443 --context argocd-cluster
        ```

    * Login to argocd-cli

        * Get the initial admin password of ArgoCD to be able to access the ArgoCD service through the UI or CLI through the following command.

            > You might need to wait for a bit for argocd to create the secret. 
            > You could run `kubectl wait -n argocd --for=create secret/argocd-initial-admin-secret --timeout=300s --context argocd-cluster` and when it returns successfully you can proceed.

            ```sh
            ~$ argoPassword=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
            ```

        * You can now login using the argocd-cli and then using the same credentials login to the argocd-ui
            ```sh
            ~$ argocd login --insecure 127.0.0.1:8181 --username admin --password $argoPassword
            ```

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- ArgoCD Applications and ApplicationSets Workshop -->
## ArgoCD Applications and ApplicationSets Workshop

### ArgoCD Application

`Application` is an argocd custom resource which takes the manifests from a source, then deploy them to a desired cluster and namespace. The source could contain:  
* Raw Kubernetes manifest
* Kustomize overlay
* Helm chart
* Kustomize helm
* Other argocd CRs ;)

In this section you can see how easy it is to get an app deployment to a Kubernetes cluster up and running with ArgoCD.

* The basic structure of the Application custom resource. For a more extensive dive check out <a href="https://argo-cd.readthedocs.io/en/stable/user-guide/application-specification/">the Application CR specifications</a>

```yaml
# application.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-application                  # Name of the application in ArgoCD
  namespace: argocd                     # Namespace where ArgoCD is installed
spec:
  # The project the application belongs to.
  project: default

  # Source of the application manifests
  source:
    repoURL: https://domain.com/user/repo.git   # URL to the git repository holding the kubernetes manifests of the application
    targetRevision: HEAD                        # The revision is a git reference (branch, commit SHA, ...)
    path: path/to/manifests-target              # Path to the directory holding the manifests (kustomize overlay, helm chart, other argocd apps, ...) from the repository root

  # Destination cluster and namespace to deploy the application
  destination: 
    server: https://kubernetes.default.svc      # Cluster API URL
    # name: in-cluster                          # Or cluster name
    # The namespace will only be set for namespace-scoped resources that have not set a value for .metadata.namespace
    namespace: guestbook                        # Namespace to have the manifests deployed to

  # Sync policy: Controls synchronization behavior
  syncPolicy:
    automated:                          # Enables automated synchronization
      prune: true                       # Automatically deletes resources not defined in the source
      selfHeal: true                    # Automatically detects and fixes drifted resources
    syncOptions:                        # Additional synchronization options
    - CreateNamespace=true              # Automatically creates the target namespace if it doesn't exist

  # Retry strategy: Configures retries for failed syncs
  retry:
    limit: 5                            # Number of retry attempts for a failed sync
    backoff:
      duration: "10s"                   # Initial backoff duration (10 seconds)
      factor: 2                         # Exponential backoff multiplier
      maxDuration: "5m"                 # Maximum backoff duration (5 minutes)
```


1. Apply the `gitops/application.yaml` file.
    ```sh
    ~$ kubectl apply -f gitops/application.yaml --context argocd-cluster
    ```
    The application should pop up almost immediately on the ArgoCD UI open in the browser. Click on the application that popped up and you should see something similar to
    ![in-argo-app][in-argo-app]

2. Since in the `application.yaml` we did not specify `automated` in the `syncPolicy` argocd is aware that the manifests exist but is doing nothing to apply them. Lets click on the "Sync" button and you should see something like this:
    ![argo-app-sync][argo-app-sync]

3. Click on the "Synchronize" button to deploy manually and watch the go webapp come to life, you should see something similar to:
    ![argo-app-healthy][argo-app-healthy]

4. View the go webapp in the browser
    * If using the `docker` driver then you need to tunnel the argocd-cluster to localhost using
        ```sh
        # Minikube will tunnel the ingress
        ~$ minikube tunnel -p argocd-cluster
        ```
        > __NOTE__: This will ask for sudo permissions

    * Open your Browser and go to the link `http://CLUSTER_IP/go` where `CLUSTER_IP=$(minikube ip -p argocd-cluster)`, you should see the following respectively
        > If using the `docker` driver then you should navigate to `http://localhost/go`

        ![go-webapp-dev][go-webapp-dev]

5. Redo steps 1 -> 4 but with the automated syncing and deployment of argocd.
    * Delete the argocd app
    ```sh
    ~$ argocd app delete go-webapp-dev -y
    ```
    * Apply the `application.yaml` file again but with a different `syncPolicy`
    ```yaml
    ...
    syncPolicy:
      automated:
        selfHeal: true
        prune: true
      syncOptions:
        - CreateNamespace=true    # Letting argocd be responsible for creating the namespace(s) of the manifests reffered to in the /spec/source
     ```

6. Delete the argocd application
    * You can use the UI intuitively or using the following command
    ```sh
    ~$ argocd app delete go-webapp-dev -y
    ```

<p align="right">(<a href="#readme-top">back to top</a>)</p>


### ArgoCD ApplicationSet

`ApplicationSet` is an argocd custom resource that allows the generation of argocd `Application`.
Checkout <a href="https://argo-cd.readthedocs.io/en/latest/user-guide/application-set/">the ApplicationSet user guide</a> for a comprehensive dive.


* The basic structure of the Application custom resource. For a more extensive dive check out <a href="https://argo-cd.readthedocs.io/en/stable/user-guide/application-specification/">the Application CR specifications</a>.
> Note: There are many more generators that can be found <a href="https://argo-cd.readthedocs.io/en/latest/operator-manual/applicationset/Generators/">here</a>

```yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: appset-name
spec:
  generators:
    # Merge generator
    - merge: 
        mergeKeys:                                            # Use the selector set by both child generators to combine them.
          - nameNormalized
        generators:
          # List generator
          - list:
              elements:
                - name: cluster1
                  server: https://1.2.3.4
                  nameNormalized: app1
                  repoURL: https://domain.com/user/repo.git   # URL to the git repository holding the kubernetes manifests of the application
                  path: path/to/manifests-target              # Path to the directory holding the manifests (kustomize overlay, helm chart, other argocd apps, ...) from the repository root
                  namespace: app1-ns
                - name: cluster2
                  server: https://5.6.7.8
                  nameNormalized: app2
                  repoURL: https://domain.com/user/repo.git   # URL to the git repository holding the kubernetes manifests of the application
                  path: path/to/manifests-target              # Path to the directory holding the manifests (kustomize overlay, helm chart, other argocd apps, ...) from the repository root
                  namespace: app2-ns
          # Cluster generator
          - clusters:
              selector:
                matchLabels:                                  # This can be done with `argocd cluster set CLUSTER_NAME --label key=value`
                  environment: dev                            # Select a cluster with a label environment=dev
  template:                                                   # Application specification same as earlier in the workshop
    metadata:
      name: 'dev-{{nameNormalized}}'
    spec:
      project: default
      source:
        repoURL: '{{repoURL}}'
        targetRevision: HEAD
        path: '{{path}}'
      destination:
        name: '{{name}}'
        namespace: '{{namespace}}'
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
```

1. Apply the `gitops/applicationset.yaml` file.
    ```sh
    ~$ kubectl apply -f gitops/applicationset.yaml --context argocd-cluster
    ```
    The applications should pop up almost immediately on the ArgoCD UI Applications dashboard open in the browser. Click on the application that popped up and you should see something similar to
    ![post-appset-dashboard][post-appset-dashboard]


2. View the go and fastapi webapps in the browser
    * Open your Browser and go to the links `http://CLUSTER_IP/go` and `http://CLUSTER_IP/fastapi` where `CLUSTER_IP=$(minikube ip -p argocd-cluster)`, you should see the following respectively
        > __NOTE__: If using the `docker` driver then you should navigate to `http://localhost/go` and `http://localhost/fastapi`. The `minikube tunnel -p argocd-cluster` should still be running for this to work

        ![go-webapp-prod][go-webapp-prod]
        ![fastapi-webapp-prod][fastapi-webapp-prod]

3. Close the terminal holding the `minikube tunnel -p argocd-cluster` (if using the `docker` driver) and the terminal serving of the argocd-server in <a href="#setup">Setup</a> (Step 9)

4. Tear down the cluster
    ```sh
    ~$ minikube stop -p argocd-cluster
    ~$ minikube delete -p argocd-cluster
    ```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- ArgoCD App of Apps Pattern Workshop -->
## ArgoCD App of Apps Pattern Workshop

The app of apps pattern is when a parent application (the “App of Apps”) is defined in ArgoCD, which references to multiple child applications. Each child application has its own manifest or Helm chart, enabling independent management and scaling.

### Multi Cluster Setup
I will be simulating multiple clusters to showcase how the app of apps pattern (using Applications and/or ApplicationSets) can be used for multi cluster deployments.

1. Setup the clusters using the convenient well commented script in `.hack/clusters-up.sh` in a dedicated terminal instance. Please make sure to take a look at the shell script and read the comments.
    ```sh
    # If on Linux then this should be fine
    ~$ ./.hack/clusters-up.sh

    # If on macOS then sudo will be needed for appending an entry to /etc/hosts before spinning up the clusters
    ~$ echo "$(ifconfig en0 | awk '/inet / {print $2}') argocd-workshop.com" | sudo tee -a /etc/hosts
    ~$ ./.hack/clusters-up.sh
    ```

2. Login to the <a href="https://127.0.0.1:9797">ArgoCD UI</a>
    * Get the initial admin password of ArgoCD to be able to access the ArgoCD service through the UI

        ```sh
        ~$ argoPassword=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
        ```
    >The `./.hack/clusters-up.sh` script logs you in to the argocd cli

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### App of Apps
In here we will see how deploying the Application CR (the "App of Apps") will deploy both webapps in the dev-cluster/prod-cluster using the Application CRs responsible for each webapp.  

1. Apply the development and production overlays of `gitops/apps/app-of-apps`.
    ```sh
    ~$ kubectl apply -k gitops/apps/app-of-apps/overlays/dev --context argocd-cluster
    ~$ kubectl apply -k gitops/apps/app-of-apps/overlays/prod --context argocd-cluster
    ```

    * The application `dev-app-of-apps` and `prod-app-of-apps` should pop up almost immediately on the ArgoCD UI open in the browser alongside the other dev/prod applications it spins up. Click on the `dev-app-of-apps` application that popped up and you should see something similar to
    ![in-argo-app-of-apps-dev][in-argo-app-of-apps-dev]

2. View the dev-cluster webapps in the browser
    * If using the `docker` driver then you need to tunnel the dev-cluster to localhost using
        ```sh
        ~$ minikube tunnel -p dev-cluster
        ```
    * Open your Browser and go the link `http://CLUSTER_IP/go` and `http://CLUSTER_IP/fastapi` where `CLUSTER_IP=$(minikube ip -p dev-cluster)`, you should see the following respectively
        > If using the `docker` driver then you should navigate to `http://localhost/go` and `http://localhost/fastapi`

        ![go-webapp-dev][go-webapp-dev]
        ![fastapi-webapp-dev][fastapi-webapp-dev]


3. View the prod-cluster webapps in the browser
    * If using the `docker` driver then you need to tunnel the prod-cluster to localhost using
        ```sh
        ~$ minikube tunnel -p prod-cluster
        ```
    * Open your Browser and go the link `http://CLUSTER_IP/go` and `http://CLUSTER_IP/fastapi` where `CLUSTER_IP=$(minikube ip -p prod-cluster)`, you should see the following respectively
        > If using the `docker` driver then you should navigate to `http://localhost/go` and `http://localhost/fastapi`

        ![go-webapp-prod][go-webapp-prod]
        ![fastapi-webapp-prod][fastapi-webapp-prod]

4. Tear down the dev and prod app-of-apps
    ```sh
    ~$ argocd app delete dev-app-of-apps -y
    ~$ argocd app delete prod-app-of-apps -y
    ```

<p align="right">(<a href="#readme-top">back to top</a>)</p>


### App of AppSets
In here we will see how deploying the Application CR (the "App of Appsets") will deploy both webapps in both the dev-cluster and prod-cluster using one ApplicationSet CR responsible for the webapps.

1. Apply the development and production overlays of `gitops/appsets/app-of-appsets`.
    ```sh
    ~$ kubectl apply -k gitops/appsets/app-of-appsets/overlays/dev --context argocd-cluster
    ~$ kubectl apply -k gitops/appsets/app-of-appsets/overlays/prod --context argocd-cluster
    ```
    The applications should pop up almost immediately on the ArgoCD UI open in the browser. Click on the applications named `dev-app-of-appsets` that popped up and you should see something similar to
    ![in-argo-app-of-appsets-dev][in-argo-app-of-appsets-dev]

2. Do the same steps in the <a href="#app-of-apps">app of apps section</a> (steps 2,3)

3. Tear down the clusters using the convenient `.hack/clusters-down.sh`. Please make sure to take a look at the shell script.
    ```sh
    # If on Linux then this should be fine
    ~$ ./.hack/clusters-down.sh

    # If on macOS then sudo will be needed for removing the entry in /etc/hosts related to argocd-workshop.com before tearing down the clusters
    ~$ sudo sed -i '' '/argocd-workshop.com/d' /etc/hosts
    ~$ ./.hack/clusters-down.sh
    ```

<p align="right">(<a href="#readme-top">back to top</a>)</p>


<!-- LICENSE 
## License

Distributed under the MIT License. See `LICENSE.txt` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>
-->


<!-- CONTACT -->
## Contact
Connect with me on 

[![LinkedIn][linkedin-shield]][linkedin-url]

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- ACKNOWLEDGMENTS -->
## Acknowledgments

* [Best README Template](https://github.com/othneildrew/Best-README-Template/)
* [Original News Demo Project](https://github.com/Freshman-tech/news-demo-starter-files)
* [Multi Cluster Minikube ArgoCD](https://wave-s.notion.site/minikube-argocd-4126495087164d66a3aa8629fd6ec138)

<p align="right">(<a href="#readme-top">back to top</a>)</p>


<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://markdownguide.org/basic-syntax/#reference-style-links -->

[linkedin-shield]: https://img.shields.io/badge/linkedin-0769AD?style=for-the-badge&logo=linkedin&logoColor=white
[linkedin-url]: https://linkedin.com/in/faisalalrayyess

[in-argo-app]: readme-images/in-argo-app.png
[in-argo-app-of-apps-dev]: readme-images/in-argo-app-of-apps-dev.png
[in-argo-app-of-apps-prod]: readme-images/in-argo-app-of-apps-prod.png
[in-argo-app-of-appsets-dev]: readme-images/in-argo-app-of-appsets-dev.png
[argo-app-sync]: readme-images/argo-app-sync.png
[argo-app-healthy]: readme-images/argo-app-healthy.png
[go-webapp-dev]: readme-images/go-webapp-dev.png
[go-webapp-prod]: readme-images/go-webapp-prod.png
[fastapi-webapp-dev]: readme-images/fastapi-webapp-dev.png
[fastapi-webapp-prod]: readme-images/fastapi-webapp-prod.png
[post-appset-dashboard]: readme-images/post-appset-dashboard.png

[FastAPI]: https://img.shields.io/badge/fastapi-white?style=for-the-badge&logo=fastapi&logoColor=009485
[FastAPI-url]: https://fastapi.tiangolo.com/

[Python]: https://img.shields.io/badge/python-306998?style=for-the-badge&logo=python&logoColor=white
[Python-url]: https://www.python.org/

[Go]: https://img.shields.io/badge/go-306998?style=for-the-badge&logo=go&logoColor=white
[Go-url]: https://go.dev/

[Docker]: https://img.shields.io/badge/docker-0769AD?style=for-the-badge&logo=docker&logoColor=white
[Docker-url]: https://docker.com/

[kubernetes]: https://img.shields.io/badge/kubernetes-F5F5F5?style=for-the-badge&logo=kubernetes&logoColor=3970e4
[kubernetes-url]: https://kubernetes.io/

[Github]: https://img.shields.io/badge/github-1a1a1a?style=for-the-badge&logo=github&logoColor=F5F5F5
[Github-url]: https://github.com/

[ArgoCD]: https://img.shields.io/badge/argocd-F5F5F5?style=for-the-badge&logo=argo&logoColor=orange
[ArgoCD-url]: https://argoproj.github.io/cd/
