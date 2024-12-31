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
    <li><a href="#contributing">Contributing</a></li>
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

1. Have a <a href="https://github.com/">GitHub</a> account

2. Have a <a href="https://www.docker.com/">Docker</a> account

3. Be familiar with the basics of <a href="https://kustomize.io/">kustomize</a>.

4. Ensure that you have docker installed on your machine. To install docker please follow the instructions of installation on the <a href="https://docker.com/">Docker Official Website</a>
according to your operating system.

5. Ensure that docker is installed correctly by typing the following command in your shell and getting a response that looks like this
  ```sh
  ~$ docker --version
  Docker version XX.XX.XX ...
  ```
  >At the time of initiating the workshop version 24.4.0 of Docker was used.

6. Ensure that you have minikube installed on your machine to simulate a Kubernetes cluster locally. To install minikube please follow the instructions of installation on the <a href="https://minikube.sigs.k8s.io/docs/start/">Minikube Official Installation Page</a> according to your operating system.

7. Ensure that minikube is installed correctly by typing the following command in your shell and getting a response that looks like this
  ```sh
  ~$ minikube version
  minikube version: vX.XX.X
  commit: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  ```
  >At the time of initiating the workshop version 1.34.0 of Minikube was used.

8. Install ArgoCD CLI to try and get familiar with controlling the ArgoCD pipeline from the terminal. Use the instructions on the <a href="https://argo-cd.readthedocs.io/en/stable/cli_installation/">ArgoCD CLI Installation Page</a>. You can check if the installation was successful by running the following command in your shell and getting a response that looks like this
  ```sh
  ~$ argocd version
    argocd: vX.X.X+XXXXXXX
        BuildDate: XXXX-XX-XXXXX:XX:XXX
        GitCommit: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
        GitTreeState: XXXXX
        GoVersion: goX.XX.XX
        Compiler: XX
        Platform: XXXXXXX/XXXXX
    argocd-server: vX.X.X+XXXXXXX.XXXXX
  ```
  >At the time of initiating the workshop workshop version 2.13.2 of ArgoCD CLI was used.

9. [Optional] Install <a href="https://www.oracle.com/es/virtualization/technologies/vm/downloads/virtualbox-downloads.html">VirtualBox</a> (if on amd64 arch) or <a href="https://www.parallels.com/">Parallels</a> (if on macOS arm64 arch)
  >If you would like to do the more advanced multi-cluster ArgoCD deployments and the app of apps pattern then this is required.

### Setup

1. Fork this repository to have your own copy which you could modify.
This is important to be able to save your own repository secrets.

2. Use your own image repositories
    * Create two public image repositories in your Docker account named as follows:
        * fastapi-argocd-workshop
        * go-argocd-workshop
    * Replace all "image: falrayes/..." with "image: <YOUR_DOCKER_USERNAME>/..."

3. Use your own forked repository
    * Replace all "repoURL: https://github.com/FaisalAl-Rayes/argocd-workshop.git" with "repoURL: https://github.com/<YOUR_GITHUB_USERNAME>/argocd-workshop.git" in the following paths:
        * `gitops/app-of-apps.yaml`
        * `gitops/app-of-appsets.yaml`
        * `gitops/application.yaml`
        * `gitops/applicationset.yaml`

3. For the sake of simplicity you will do the forbidden: Commit and push the changes to master/main >:)

4. Generate a GitHub access token (with repo and workflow scopes enabled) for the CI workflow to commit into your repo with updated images, then store it into the forked repository secrets as `GIT_WORKFLOWS_TOKEN`
    * To generate a GitHub access token (classic) go to your profile settings > Developer Settings > Personal access tokens > Tokens (classic)

5. Store your docker username into the forked repositories secrets as `DOCKER_USERNAME`

6. Create a docker access token (with read and write scopes enabled) for the CI workflow to build and push to your docker repositories, then store it into the forked repository secrets as `DOCKER_TOKEN`
    * To generate a docker personal access token go to your profile settings > Personal access tokens

7. Run the CI workflow of the repo to create and push the first image tags
    * Go to `https://github.com/FaisalAl-Rayes/argocd-workshop/actions/workflows/ci.yaml`
    * Click on `Run workflow` and select the `master` branch

8. Using Minikube with Docker as the driver, start a Kubernetes cluster with 3 worker nodes running Kubernetes version 1.27.3 by running the following command.
   ```sh
   ~$ minikube start --driver=docker -p argocd-workshop
   ```
   > This process might take some time if it is the first start up of minikube.

9. Install ArgoCD in the Kubernetes cluster by running the following commands.
   ```sh
   ~$ kubectl create namespace argocd
   ~$ kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
   ```
   >These commands are taken from <a href="https://argo-cd.readthedocs.io/en/stable/getting_started/">ArgoCD Installation Page</a>. Make sure that the official page takes priority over the commands in above.


10. Run one of the following commands to serve the ArgoCD service on your local machine in a different terminal instance. Whatever URL (127.0.0.1:port) you get from this we will call argoURL.
    ```sh
    # You can choose a port of your choosing that is not in use. I will use 8181
    ~$ kubectl port-forward -n argocd svc/argocd-server 8181:443 --context argocd-cluster
    or
    # Minikube will assign the port
    ~$ minikube -p argocd-cluster service argocd-server -n argocd
    ```

11. Login to argocd-cli

    * Get the initial admin password of ArgoCD to be able to access the ArgoCD service through the UI or CLI through the following command.

        > You might need to wait for a bit for argocd to create the secret. 
        > You could run `kubectl wait -n argocd --for=create secret/argocd-initial-admin-secret --timeout=300s --context argocd-cluster` and when it returns successfully you can proceed.

        ```sh
        ~$ argoPassword=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
        ```

    * You can now login using the argocd-cli and then using the same credentials login to the argocd-ui
        ```sh
        # NOTE: If you let minikube service the argocd-server then use the port it has assigned.
        # In the command bellow I am assuming that it is being ran on port 8181.
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

4. Use `minikube tunnel` in a separate terminal to serve the webapp.
    ```sh
    # Minikube will tunnel the ingress
    ~$ minikube tunnel -p argocd-cluster
    ```
    > __NOTE__: This will ask for sudo permissions

5. Open your Browser and go the link `localhost/go`.
    ![go-webapp-dev][go-webapp-dev]

6. Redo steps 1 -> 5 but with the automated syncing and deployment of argocd.
    * Delete the argocd app
    ```zsh
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

7. Delete the argocd application
    * You can use the UI intuitively or using the following command
    ```zsh
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


2. Open your Browser and go the link `localhost/go` and then `localhost/fastapi`, you should see the following respectively
    ![go-webapp-prod][go-webapp-prod]
    ![fastapi-webapp-prod][fastapi-webapp-prod]
    > __NOTE__: The `minikube tunnel -p argocd-cluster` should still be running for this to work

3. Close the terminal holding the `minikube tunnel -p argocd-cluster` and the serving of the argocd-server in <a href="#setup">Setup</a> (Step 9)

4. Tear down the cluster
    ```zsh
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
    ```zsh
    ~$ ./.hack/clusters-up.sh
    ```

2. Login to the <a href="https://127.0.0.1:9797">ArgoCD UI</a>
    * Get the initial admin password of ArgoCD to be able to access the ArgoCD service through the UI

        ```sh
        ~$ argoPassword=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
        ```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### App of Apps
In here we will see how deploying the one Application CR (the "App of Apps") will deploy the webapp in both the dev-cluster and prod-cluster using the Application CRs responsible for each webapp.  
Files of concern (4 Application CRs `gitops/apps/*` + app of appsets Application CR `gitops/app-of-apps.yaml`)

1. Apply the `gitops/app-of-apps.yaml` file.
    ```zsh
    ~$ kubectl apply -f gitops/app-of-apps.yaml --context argocd-cluster
    ```
    The application `app-of-apps` should pop up almost immediately on the ArgoCD UI open in the browser alongside the other applications it spins up. Click on the `app-of-apps` application that popped up and you should see something similar to
    ![in-argo-app-of-apps][in-argo-app-of-apps]

2. [Precaution] Get the IP addresses of the `dev-cluster` and `prod-cluster` using minikube cli in case minikube did not automatically add entries to `/etc/hosts` with the profile names mapped to their IP.
    ```zsh
    ~$ minikube ip -p dev-cluster
    ~$ minikube ip -p prod-cluster
    ```

3. Open your Browser and go the link `http://dev-cluster/go` and then `http://dev-cluster/fastapi`, you should see the following respectively
    ![go-webapp-dev][go-webapp-dev]
    ![fastapi-webapp-dev][fastapi-webapp-dev]

4. Open your Browser and go the link `http://prod-cluster/go` and then `http://prod-cluster/fastapi`, you should see the following respectively
    ![go-webapp-prod][go-webapp-prod]
    ![fastapi-webapp-prod][fastapi-webapp-prod]

5. Tear down the app-of-apps
    ```zsh
    ~$ argocd app delete app-of-apps -y
    ```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### App of AppSets
In here we will see how deploying the one Application CR (the "App of Appsets") will deploy the webapps in both the dev-cluster and prod-cluster using the ApplicationSet CRs responsible for each webapp.
Files of concern (2 ApplicationSet CRs `gitops/appsets/*` + app of appsets Application CR  `gitops/app-of-appsets.yaml`)

1. Apply the `gitops/app-of-appsets.yaml` file.
    ```sh
    ~$ kubectl apply -f gitops/app-of-appsets.yaml --context argocd-cluster
    ```
    The application should pop up almost immediately on the ArgoCD UI open in the browser. Click on the application that popped up and you should see something similar to
    ![in-argo-app-of-appsets][in-argo-app-of-appsets]

3. Do the same steps in the <a href="#app-of-apps">app of apps section (steps 2,3,4)</a>

2. Tear down the clusters using the convenient `.hack/clusters-down.sh`. Please make sure to take a look at the shell script.
    ```zsh
    ~$ ./.hack/clusters-down.sh
    ```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1. Fork the Repository
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

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

<p align="right">(<a href="#readme-top">back to top</a>)</p>


<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://markdownguide.org/basic-syntax/#reference-style-links -->

[linkedin-shield]: https://img.shields.io/badge/linkedin-0769AD?style=for-the-badge&logo=linkedin&logoColor=white
[linkedin-url]: https://linkedin.com/in/faisalalrayyess

[in-argo-app]: readme-images/in-argo-app.png
[in-argo-app-of-apps]: readme-images/in-argo-app-of-apps.png
[in-argo-app-of-appsets]: readme-images/in-argo-app-of-appsets.png
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
