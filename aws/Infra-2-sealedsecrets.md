# Infrastructure encrypted secrets with [SealedSecrets](https://github.com/bitnami-labs/sealed-secrets)

Kubernetes controller and tool for one-way encrypted Secrets.

Sealed Secrets provides declarative Kubernetes Secret Management in a secure way. Since the Sealed Secrets 
are encrypted, they can be safely stored in a code repository. This enables an easy to implement GitOps flow 
that is very popular among the OSS community.

### Prerequisites

There are two parts to Sealed Secrets:
1. CLI utility called `kubeseal`
2. SealedSecrets k8s Controller 

--------------------------------------------
* k8s cluster
  * kubectl pointing to the right k8s context
* istio installed
* cert-manager installed

--------------------------------------------

### Step 0 - Decide on specific version
The two supporting pieces of SealedSecrets need to match versions. Visit their [Github](https://github.com/bitnami-labs/sealed-secrets/releases)
site and pick a release version that suits your needs. The subsequent steps in this readme use version `0.26.2`. As of this 
writing `homebrew` on OSX has version `0.26.2` available and no other version. 

### Step 1 - Install `kubeseal` CLI
* Linux:
  * https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.26.2/kubeseal-0.26.2-linux-amd64.tar.gz
  * ```bash
    # Install the kubeseal cli version 0.26.2
    wget https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.26.2/kubeseal-0.26.2-linux-amd64.tar.gz

    tar -xf kubeseal-0.26.2-linux-amd64.tar.gz

    sudo install -m 755 kubeseal /usr/local/bin/kubeseal
    ```
* OSX:
  * Use `homebrew` to install the CLI
    * https://formulae.brew.sh/formula/kubeseal
  * ```bash
    brew install kubeseal
    ```
    
### Step 2 - Install the k8s controller 
Download the controller from the SealedSecrets release and apply to the cluster via kubectl/kustomize. Version `0.26.2`
of the controller has been downloaded and stored under the `sealed-secrets` distribution folder in this repo. 
* Download the controller if you need a new version using `wget`
  * ```bash
    wget https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.26.2/controller.yaml
    ```
* Install the controller from the distribution/sealed-secrets folder using `kustomize`
  * ```bash
    # Install the Sealed-Secrets controller on the cluster
    kustomize build distribution/sealed-secrets/ | kubectl apply -f -
    ```