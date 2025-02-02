#!/bin/bash
ARGOCD_SECRETS_PATH="./secrets"

# Execute:
# ./setup_dex_oauth_credentials.sh --oauthclientid youroauthclientid --oauthclientsecret youroauthclientsecret --organization oauthorganization --team araneae

team=${team:-araneae} # The organization team the user should belong to
organization=${organization:-something} # The oauth application's client id
oauthclientid=${oauthclientid:-somethingtwo} # The oauth application's client id
oauthclientsecret=${oauthclientsecret:-anothersomething} # The oauth application's client secret

while [ $# -gt 0 ]; do

   if [[ $1 == *"--"* ]]; then
        param="${1/--/}"
        declare "$param"="$2"
        echo "$1" "$2" # Optional to see the parameter:value result
   fi

  shift
done

kubectl create secret generic -n argocd dex-oauth --from-literal=dex.github.clientId="${oauthclientid}" --from-literal=dex.github.clientSecret="${oauthclientsecret}" --from-literal=dex.github.team="${team}" --from-literal=dex.github.organization="${organization}" --dry-run=client -o yaml | yq eval -P ".metadata.labels.\"app.kubernetes.io/part-of\" = \"argocd\"" - | kubeseal | yq eval -P > ${ARGOCD_SECRETS_PATH}/dex-oauth.yaml


