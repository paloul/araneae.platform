# Infrastructure support for DNS Entries

Configure external DNS servers (AWS Route53, Google CloudDNS and others) for Kubernetes Ingresses and Services

Instructions and scripts to install [external-dns](https://github.com/kubernetes-sigs/external-dns).

## Prerequisite Supporting CLI Tools and Utilities

--------------------------------------------
* [istio](https://istio.io)
  * Istio should be installed and an IngressGateway defined as a LoadBalancer.
  * https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/istio.md
* [Route53](https://aws.amazon.com/route53/)
  * External DNS is not a DNS server itself, but merely configures other DNS providers accordingly.
  * In the case of AWS, we use Route53. External DNS does support others.
--------------------------------------------

### Step 1 - Create an IAM User with Route53 privileges to modify records
External DNS needs to be able to modify Route53 records. The simplest way is to create a new IAM User just for 
this purpose, with the sole privileges to only modify our Hosted Zone ID.

* https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/aws.md#iam-policy
* https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/aws.md#static-credentials

The JSON policy named `externaldns-route53-Z03766603NEQGG30JJN7-policy.json` is provided as an example. The 
Hosted Zone ID in the policy needs to match the Hosted Zone ID defined in the manifest definition.
```bash
aws iam create-group --profile araneae --group-name externaldns-route53

aws iam create-policy \
  --profile araneae \
  --policy-name externaldns-route53-Z03766603NEQGG30JJN7 \
  --policy-document file://aws/externaldns-route53-Z03766603NEQGG30JJN7-policy.json
  
aws iam attach-group-policy \
  --profile araneae \
  --group-name externaldns-route53 \
  --policy-arn arn:aws:iam::654383687924:policy/externaldns-route53-Z03766603NEQGG30JJN7
  
aws iam create-user --profile araneae --user-name externaldns-route53

aws iam add-user-to-group \
  --profile araneae \
  --user-name externaldns-route53 \
  --group-name externaldns-route53

# Make note of the access key and its secret key generated 
aws iam create-access-key --profile araneae --user-name externaldns-route53
```

### Step 2 - Create Sealed Secret of IAM Access ID and Secret Key
```bash
./external-dns-secret.sh --accesskeyid iamuseraccessid --accesssecretkey iamuseraccesssecretkey
```

### Step 3 - Apply Kustomize YAML
```bash
kustomize build distribution/externaldns/ | kubectl apply -f -
```