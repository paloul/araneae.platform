# Araneae Platform

---

## *What it is*

---
A bootstrapped set of instructions and infrastructure code to deploy and host an application
with all the necessary utility services to enable it as a platform using Kubernetes. 

## *Why it exists*

---
Needed a robust platform to deploy cloud-native applications without using the cloud provider's 
native services in order to stay agnostic and free from one cloud-provider to another.  

## *How its made*

---
Makes use of GitOps best-practices and leverages ArgoCD to deploy all the various pieces. Additionally, 
it heavily documents the processes, steps, commands to get low-level infrastructure pieces deployed prior
to ArgoCD. Those low-level infrastructure pieces are k8s using KOPS on AWS, istio for the service mesh, 
and various others using Helm or k8s manifests such as Sealed Secrets, External DNS and Cert Manager.

## *Get Started*

---
Detailed instructions can be found in their respective cloud provider folders starting with 
the Infra-0-kops.md file, e.g. [AWS/Infra-0-kops.md](aws/Infra-0-kops.md).