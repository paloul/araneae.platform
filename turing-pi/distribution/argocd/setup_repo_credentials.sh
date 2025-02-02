#!/bin/bash
ARGOCD_SECRETS_PATH="./secrets"

# Execute:
# ./setup_repo_credentials.sh --githttpsusername yourgituser --githttpspassword yourgitpwd --githttpsrepo yourgitrepourl

githttpsrepo=${githttpsrepo:-"https://github.com/paloul/default-repo.git"}
githttpsusername=${githttpsusername:-admin} # The Git repo's https username as default admin
githttpspassword=${githttpspassword:-password} # The Git repo's https password as default admin

while [ $# -gt 0 ]; do

   if [[ $1 == *"--"* ]]; then
        param="${1/--/}"
        declare "$param"="$2"
        echo "$1" "$2" # Optional to see the parameter:value result
   fi

  shift
done

kubectl create secret generic -n argocd private-https-repo --from-literal=type="git" --from-literal=username="${githttpsusername}" --from-literal=password="${githttpspassword}" --from-literal=url="${githttpsrepo}" --dry-run=client -o yaml | yq eval -P ".metadata.labels.\"argocd.argoproj.io/secret-type\" = \"repository\"" - | kubeseal | yq eval -P > ${ARGOCD_SECRETS_PATH}/private-https-repo.yaml


