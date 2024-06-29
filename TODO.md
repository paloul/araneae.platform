# To Do 
Keep track of what *to do* next and maintain a history of what was done. 

### To Do
- [ ] Rook-Ceph data infrastructure
- [ ] Apache Pulsar cluster
  - [ ] Separate Function runtime with k8s 
- [ ] Implement and integrate auto-renewal for cert-manager owned certificates
- [ ] istio-egressgateway
  - [ ] Enable egress gateway
  - [ ] Enable egress through istio-egressgateway
  - [ ] Network policies to enable egress **only** through istio-egressgateway


### In Progress
- [ ] Minimize instance types of kops nodes
- [ ] Apply nodes labels and taints to kops instance groups
  - [ ] Apply taint tolerations to the infra utility pieces 

### Done
- [x] Format To Do file
- [x] Initial configuration with Istio, SealedSecrets, CertManager
- [x] Working configuration, security and routable ArgoCD
- [x] Find out if istio annotations `traffic.sidecar.istio.io/excludeOutboundIPRanges` necessary for some Argo pods
  - Looks like it's not needed, but it does play a part when containers become ready before istio-proxy is
- [x] ExternalDNS
  - [x] Readme for ExternalDNS for automatic dns entries
  - [x] Test execute the instructions in the ExternalDNS readme file
  - [x] Implement ExternalDNS for automatic dns entries


