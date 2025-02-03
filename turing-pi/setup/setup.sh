#!/bin/bash

# This script is a rundown of the manual steps taken to setup and configure the araneae platform for gitflow
# practice using ArgoCD. It preps the environment to support deployment of the application with ArgoCD.
# It is not intended to be run as a complete end-to-end script to configure. Review it and choose
# the steps needed.

# Setup Master Node on ubuntu-rock1
curl -sfL https://get.k3s.io | sh -s - --write-kubeconfig-mode 644 --disable servicelb --token kelda-araneae --node-ip 192.168.68.68 --disable-cloud-controller --disable local-storage 

# Setup Worker nodes ubuntu-rock2, ubuntu-rock3, ubuntu-rock4
curl -sfL https://get.k3s.io | K3S_URL=https://192.168.68.68:6443 K3S_TOKEN=kelda-araneae sh -

# Set worker labels on all
kubectl label nodes ubuntu-rock1 kubernetes.io/role=worker
kubectl label nodes ubuntu-rock2 kubernetes.io/role=worker
kubectl label nodes ubuntu-rock3 kubernetes.io/role=worker
kubectl label nodes ubuntu-rock4 kubernetes.io/role=worker

############################################################
# Install Helm - ONLY ON MASTER NODE - ubuntu-rock1
# Fix kubeconfig file to prevent Helm errors
export KUBECONFIG=~/.kube/config
mkdir ~/.kube 2> /dev/null
sudo k3s kubectl config view --raw > "$KUBECONFIG"
chmod 600 "$KUBECONFIG"
echo "KUBECONFIG=$KUBECONFIG" >> /etc/environment

# Create a directory for Helm and navigate into it
mkdir ~/helm && cd helm
# Download Helm installer
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
# Modify permissions for execution
chmod 700 get_helm.sh
# Install Helm
./get_helm.sh

# Verify Helm installation
helm version
############################################################


############################################################
# Install MetalLB - https://metallb.universe.tf/ 
# DO THIS ONLY ON MASTER NODE
# Add MetalLB repository to Helm
helm repo add metallb https://metallb.github.io/metallb

# Check the added repository
helm search repo metallb

# Install metallb with helm
helm upgrade --install metallb metallb/metallb --create-namespace --namespace metallb-system --wait

# Assign IP range for MetalLB from yaml file
kubectl apply -f metallb.yaml

############################################################


############################################################
# Install Longhorn 
# On each node, ensure nfs-common, open-iscsi, and util-linux are installed
apt -y install nfs-common open-iscsi util-linux

# Ensure mount points and a directory are set up for SSDs installed and
# available to each rock-ubuntu host

# Install Longhorn - https://longhorn.io/
# DO THIS ONLY ON THE MASTER NODE
# Add longhorn to the helm  
helm repo add longhorn https://charts.longhorn.io

# Install Longhorn with the UI portal enabled and made available
# via a loadbalancer with the help of MetalLB
# The load balancer IP parameter should be from the pool available to metalLB
# The default data path should point to the mounted location of the SSD /dev/nvme0n1p1->/mnt/nvme0->/data
helm install longhorn longhorn/longhorn --namespace longhorn-system \
 --create-namespace --set defaultSettings.defaultDataPath="/data" \
 --set service.ui.loadBalancerIP="192.168.70.11" --set service.ui.type="LoadBalancer"

############################################################


############################################################
# Install KubeSeal OSX/Linux client and SealedSecrets k8s controller on the cluster

# https://github.com/bitnami-labs/sealed-secrets

# Sealed Secrets is composed of two parts:
#  1. A cluster-side controller / operator
#  2. A client-side utility: kubeseal

# The kubeseal client should be installed where the project's k8s configuration is located and source is controlled
# kubeseal can be installed either on OSX/Linux or a Master Node on the k8s cluster itself as long as kubectl to the
# cluster is available and configured, and the sealed secrets are able to be source controlled along with the project's
# k8s configuration files for ArgoCD and Gitflow processes

# As of Feb 2 2025, the latest version is 0.28.0
# Set this to, for example, KUBESEAL_VERSION='0.28.0'
KUBESEAL_VERSION='0.28.0' # The version needs to match for kubeseal cli and the controller CRD on k8s cluster

# kubeseal client installation
# OSX: Available on brew. Check the versions first, as the kubeseal client needs to match the controller on k8s
brew info kubeseal # check the version avail on Homebrew
brew install kubeseal
# OR: Linux: Manual installation, and make sure the version matches the controller you install on k8s
curl -OL "https://github.com/bitnami-labs/sealed-secrets/releases/download/v${KUBESEAL_VERSION:?}/kubeseal-${KUBESEAL_VERSION:?}-linux-amd64.tar.gz"
tar -xvzf kubeseal-${KUBESEAL_VERSION:?}-linux-amd64.tar.gz kubeseal
sudo install -m 755 kubeseal /usr/local/bin/kubeseal

# Check version installed
## ➜  ~ kubeseal --version
## kubeseal version: v0.28.0

# Install the SealedSecret CRD and server-side controller into the kube-system namespace
kubectl apply -f "https://github.com/bitnami-labs/sealed-secrets/releases/download/v${KUBESEAL_VERSION:?}/controller.yaml"
############################################################



############################################################
# Install ArgoCD - Disabled GKP - Feb 1 2025 - Installing ArgoCD via ArgoCD

## Create namespace for ArgoCD web app
#kubectl create namespace argocd
#
## Install the latest ArgoCD using their manifest file
#kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
#
## Get the admin password that was auto generated by Argo
#kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
#
## Patch the ArgoCD setting to have MetalLB assign a unique IP to ArgoCD UI portal
#kubectl patch service argocd-server -n argocd --patch '{ "spec": { "type": "LoadBalancer", "loadBalancerIP": "192.168.70.12" } }'
#
## Visit http://192.168.70.12 on your browser and use the admin password to login to ArgoCD UI portal
############################################################