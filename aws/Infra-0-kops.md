# Infrastructure with kOps (AWS)

Instructions and scripts to create infrastructure for the platform on AWS using [kOps](https://kops.sigs.k8s.io/)



## Prerequisite Supporting CLI Tools and Utilities

--------------------------------------------
* yq - *(CLI processor for yaml files)*
    * [Github page](https://github.com/mikefarah/yq)
        * `curl --silent --location "https://github.com/mikefarah/yq/releases/download/v4.2.0/yq_linux_amd64.tar.gz" | tar xz && sudo mv yq_linux_amd64 /usr/local/bin/yq`
* kubectl - *(official CLI for generic Kubernetes)*
    * [Install kubectl - OSX/Linux/Windows](https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html)
    * Install kubectl version `1.23.7`
        * `curl -o kubectl https://s3.us-west-2.amazonaws.com/amazon-eks/1.23.7/2022-06-29/bin/linux/amd64/kubectl`
        * `chmod +x ./kubectl`
        * `sudo mv kubectl /usr/local/bin/kubectl`
        * `kubectl version --short --client`
* AWS CLI - *(official CLI for AWS)*
    * [Install AWS CLI - Linux](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-linux.html#cliv2-linux-install)
    * [Upgrade AWS CLI - Linux](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-linux.html#cliv2-linux-upgrade)
* kOps - *(Production Grade k8s Installation, Upgrades and Management)*
  * [Github](https://github.com/kubernetes/kops)
  * [Main Site](https://kops.sigs.k8s.io/)
  * OSX & Linux Install using Homebrew
    * `brew update && brew install kops`
  * Install from source
    * [Github Releases](https://kops.sigs.k8s.io/getting_started/install/#github-releases)

--------------------------------------------
Before you deploy the application, you must have a k8s cluster up and running. We create the k8s
infrastructure with kOps which helps you create, destroy, upgrade and maintain 
production-grade, highly available, Kubernetes clusters and necessary cloud infra.
The following steps help you configure the tools you need to get going. 
### Step 1 - Configure `awscli`
Define your key and secret in `~/.aws/credentials`
```
[default]
aws_access_key_id = SOMETHING
aws_secret_access_key = SOMETHINGLONGER

[paloul]
aws_access_key_id = SOMETHING
aws_secret_access_key = SOMETHINGLONGER
```
If using AWS Organization sub accounts, then define your profile information (AWS Organization) in `~/.aws/config`.
```
[default]
region = us-west-2
output = json

[profile araneae]
region = us-west-2
output = json
role_arn = arn:aws:iam::113113113456:role/subaccount-araneae
source_profile = paloul
```

You must execute `awscli` commands while assuming the correct role in order  
to deploy the cluster under the right sub account. This is done with either 
the `--profile` option or the use of an environment variable `AWS_PROFILE`, 
i.e. `export AWS_PROFILE=profile1`, before executing any commands. 
Visit [here](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html#using-profiles) for information.

### Step 2 - Setup IAM User for `kops` [Instructions](https://kops.sigs.k8s.io/getting_started/aws/#setup-iam-user)
Create a dedicated IAM user for kOps under the intended sub account.

kOps requires the following IAM permissions to work correctly:
```
AmazonEC2FullAccess
AmazonRoute53FullAccess
AmazonS3FullAccess
IAMFullAccess
AmazonVPCFullAccess
AmazonSQSFullAccess
AmazonEventBridgeFullAccess
```
Create the kOps IAM user using the AWS CLI with the following commands. Be sure to define
the intended sub account profile using `--profile` inline or the environment variable `AWS_PROFILE`.
```
aws iam create-group --profile araneae --group-name kops

aws iam attach-group-policy --profile araneae --policy-arn arn:aws:iam::aws:policy/AmazonEC2FullAccess --group-name kops
aws iam attach-group-policy --profile araneae --policy-arn arn:aws:iam::aws:policy/AmazonRoute53FullAccess --group-name kops
aws iam attach-group-policy --profile araneae --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess --group-name kops
aws iam attach-group-policy --profile araneae --policy-arn arn:aws:iam::aws:policy/IAMFullAccess --group-name kops
aws iam attach-group-policy --profile araneae --policy-arn arn:aws:iam::aws:policy/AmazonVPCFullAccess --group-name kops
aws iam attach-group-policy --profile araneae --policy-arn arn:aws:iam::aws:policy/AmazonSQSFullAccess --group-name kops
aws iam attach-group-policy --profile araneae --policy-arn arn:aws:iam::aws:policy/AmazonEventBridgeFullAccess --group-name kops

aws iam create-user --profile araneae --user-name kops

aws iam add-user-to-group --profile araneae --user-name kops --group-name kops

aws iam create-access-key --profile araneae --user-name kops
```

Capture the Access Key and Secret Key from the last command and configure your AWS Credentials.
```
# You can use aws configure to set the default keys
# aws configure
[default]
aws_access_key_id = NEWSOMETHING
aws_secret_access_key = NEWSOMETHINGLONGER

[kops]
aws_access_key_id = NEWSOMETHING
aws_secret_access_key = NEWSOMETHINGLONGER

[paloul]
aws_access_key_id = SOMETHING
aws_secret_access_key = SOMETHINGLONGER
```
You can list user info with the following command:
```
aws iam --profile araneae list-users

{
    "Users": [
        {
            "Path": "/",
            "UserName": "kops",
            "UserId": "SOMETHINGID",
            "Arn": "arn:aws:iam::SOMEACCOUNTID:user/kops",
            "CreateDate": "2024-03-24T17:23:46+00:00"
        }
    ]
}
```
From this point on you should use the newly created `kops` user. If you followed the instructions
and used the `--profile` inline option to define the profile, then the `kops` user will exist under
the sub account organization. 

### Step 3 - Configure DNS and Domain
You will need a hosted zone defined in the sub account to proceed. The best and easiest option
is to host under a domain purchased and hosted via AWS and Route53. Follow the instructions to 
configure DNS under Route53 [here](https://kops.sigs.k8s.io/getting_started/aws/#configure-dns).

Test your domain for valid Name Servers:
```
dig ns subdomain.example.com

## Response
;; ANSWER SECTION:
subdomain.example.com.        172800  IN  NS  ns-1.<example-aws-dns>-1.net.
subdomain.example.com.        172800  IN  NS  ns-2.<example-aws-dns>-2.org.
subdomain.example.com.        172800  IN  NS  ns-3.<example-aws-dns>-3.com.
subdomain.example.com.        172800  IN  NS  ns-4.<example-aws-dns>-4.co.uk.

```

### Step 4 - Setup Cluster State Store for kOps
`kOps` needs a dedicated bucket to store state and representation of cluster. The bucket will
hold the source of truth for the cluster.
More information can be found [here](https://kops.sigs.k8s.io/getting_started/aws/#cluster-state-store).

```
# Create bucket in us-east-1. Do not change the region
aws s3api --profile araneae create-bucket \
    --bucket kops-state-store-araneae \
    --region us-east-1

# Enable S3 versioning
aws s3api --profile araneae put-bucket-versioning \
    --bucket kops-state-store-araneae \
    --versioning-configuration Status=Enabled
    
# Enable encryption
aws s3api --profile araneae put-bucket-encryption \
    --bucket kops-state-store-araneae \
    --server-side-encryption-configuration \
        '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'
```

### Step 5 - Create the Cluster OIDC Store for kOps
Need to host OIDC documents for ServiceAccounts to use external permissions, IAM Roles for ServiceAccounts.
More information can be found [here](https://kops.sigs.k8s.io/getting_started/aws/#cluster-oidc-store).
```
aws s3api --profile araneae create-bucket \
    --bucket kops-oidc-store-araneae \
    --region us-east-1 \
    --object-ownership BucketOwnerPreferred

aws s3api --profile araneae put-public-access-block \
    --bucket kops-oidc-store-araneae \
    --public-access-block-configuration \
        BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false

aws s3api --profile araneae put-bucket-acl \
    --bucket kops-oidc-store-araneae \
    --acl public-read
```

### Step 6 - Create kOps Cluster
Set up a few environment variables:
```
export KOPS_NAME=dev.araneae.io
export KOPS_STATE_STORE=s3://kops-state-store-araneae
export KOPS_OIDC_STORE=s3://kops-oidc-store-araneae
```
Generate a cluster configuration and write it to YAML:
```
# Be sure to have a ssh keypair named `kops`

kops create cluster \
    --name ${KOPS_NAME} \
    --cloud aws \
    --state "${KOPS_STATE_STORE}" \
    --discovery-store "${KOPS_OIDC_STORE}/${KOPS_NAME}/discovery" \
    --zones "us-west-2a,us-west-2b,us-west-2c" \
    --master-zones "us-west-2a,us-west-2b,us-west-2c" \
    --master-size m4.large \
    --node-count 3 \
    --node-size m4.xlarge \
    --networking calico \
    --topology private \
    --bastion \
    --ssh-public-key=~/.ssh/kops.pub \
    --dry-run \
    -o yaml > $KOPS_NAME.yaml
```
You can modify the YAML file and make any additions or customizations. Create the cluster with
the following commands:
```
kops create -f $KOPS_NAME.yaml
kops create secret sshpublickey $KOPS_NAME -i ~/.ssh/kops.pub
kops update cluster $KOPS_NAME --yes --admin
```
If private networking was enabled like in the example above and a bastion was also created, then
you can access the bastion host via ssh with the following:
```
# https://kops.sigs.k8s.io/bastion/#using-the-bastion

# Now you can SSH into the bastion. Substitute the administrative username of the instance's OS for <username> (`ubuntu` for  Ubuntu,  `admin` for Debian, etc.) and the bastion domain for <bastion-domain>. If the bastion doesn't have a public CNAME alias, use the domain of the assigned load balancer as the bastion domain.
ssh -A -i ~/.ssh/kops ubuntu@bastion.dev.araneae.io # Default dns entry created bastion.${KOPS_NAME}

# Now use the fowarded authentication to SSH into control-plane or worker nodes in the cluster.
ssh <username>@<node-address>

```
If more changes are necessary after cluster creation, you can make modifications to the YAML
file then proceed to update the existing cluster with the following commands:
```
kops replace -f $KOPS_NAME.yaml
kops update cluster $KOPS_NAME --yes

# Wait 10 min until cluster becomes ready
kops validate cluster --wait 15m
```
A YAML file has already been generated with necessary configuration parameters for this application.
Use the existing YAML file to create a cluster. The file can be found under `aws/kops/${KOPS_NAME}.yaml`.

Some various `kops` commands that will come in handy:
```
# Get clusters
kops get clusters

# List out Instance Groups
kops get instancegroups --name ${KOPS_NAME}

# Delete cluster
kops delete cluster --name ${KOPS_NAME} --yes
```