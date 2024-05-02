# Infrastructure Service Mesh with istio

Instructions and scripts to install [istio](https://istio.io/latest/)


## Prerequisite Supporting CLI Tools and Utilities

--------------------------------------------
* [istioctl](https://istio.io/latest/docs/reference/commands/istioctl/)
  * Istio configuration command line utility for service operators to install, debug and diagnose Istio
  * OSX
    * `brew install istioctl`
  * Linux
    * `TODO: Link or describe steps to install istioctl`

--------------------------------------------

### Step 1 - Install Istio Operator 
Install the Istio Operator which handles the management and install of Istio resources for you. 

More information is available at the [link](https://istio.io/latest/docs/setup/install/operator/).

The `istioctl` command can be used to automatically deploy the Istio operator:
```bash
istioctl operator init
```
The above command installs Istio Operator in its own namespace, `istio-operator`. The Operator will create and 
watch the `istio-system` namespace by default for new definitions and make appropriate changes to `istio-system`.  
You can proceed to install the custom resource that defines your requested configuration for `istio`. Custom 
Resources are defined as IstioOperator CRDs, located in the `istio` folder under each cloud environment 
type, i.e. AWS, GCP, Azure, etc.

### Step 2 - Deploy Istio Custom Resource for your environment
Open the `kustomization.yaml` file under the `distribution/istio` folder. Activate the istio-spec for your 
intended environment. For instance, comment out `aws/istio-spec.yaml`, define a new folder and file for GCP, 
and then define include it in `kustomization.yaml`. 

Add any new DNS domains to the External-DNS Hostnames list if necessary:  
```yaml
external-dns.alpha.kubernetes.io/hostname: argocd.dev.araneae.io
```

Apply the `yaml` specification:
```bash
kustomize build distribution/istio/ | kubectl apply -f -
```

### Step 3 - Deploy the Istio Resources that allow the platform to function
~~Identify all potential hosts and their domains. Open the file `gateway-authorization-policy.yaml` and add all
potential domains to the `hosts` array.~~ 
The `istio-resources` folder has sub-folders for each piece of the platform that require istio routing and gateways.
Duplicate a sub-folder and add functionality for any new pieces of the platform that you require.

Make changes if any are necessary, then you can apply the istio resources:
```bash
kustomize build distribution/istio-resources/ | kubectl apply -f -
```
