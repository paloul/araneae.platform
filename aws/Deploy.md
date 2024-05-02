# Deployment (AWS)

Instructions and scripts to deploy the application platform on AWS.

## Prerequisite

--------------------------------------------
* [Kustomize](https://github.com/kubernetes-sigs/kustomize) - *Template-free customization of Kubernetes YAML manifests*
  * On OSX:
    ```bash
    brew install kustomize 
    ```
  * On Linux:
    ```bash
    curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash
    sudo mv kustomize /usr/local/bin
    kustomize version
    ```