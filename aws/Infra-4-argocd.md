# Infrastructure Continuous Delivery with [argocd](https://argo-cd.readthedocs.io/en/stable/)

ArgoCD is a declarative, GitOps continuous delivery tool for Kubernetes.

### Prerequisites

-------------------------------------------- 
* https://argo-cd.readthedocs.io/en/stable/
* k8s cluster 
* kustomize
* SealedSecrets
* istio
* cert-manager

--------------------------------------------

### Step 1 - Generate Sealed Secret for access to Github private repository
A Sealed Secret is needed to be created to access private git repositories. In the case of Github, generate a
Personal Access Token. This token will be paired to your Github user and grant you the ability to avoid using 
your actual Github password.  
```bash
./setup_repo_credentials.sh --githttpsusername paloul --githttpspassword personal_access_token --githttpsrepo https://github.com/paloul/araneae.platform.git
```
### Step 2 - Generate Sealed Secret to connect ArgoCD to Github as ID Provider via oauth2
ArgoCD is configured to use its own internal Dex as its federated OpenID provider. Single Sign On is configured for Dex 
to connect to Github as the ID Provider. You should have oAuth client application generated within your Github account.
The Sealed Secret generated in this step will store the Github oauth Client ID and its Client Secret for Dex to connect
and authenticate against Github. 
```bash
./setup_dex_oauth_credentials.sh --oauthclientid youroauthclientid --oauthclientsecret youroauthclientsecret --organization paloul-cicd
```
### Step 3 - Deploy ArgoCD
From the root directory of this project execute the following:
```bash
kustomize build distribution/argocd/ | kubectl apply -f -
```
