#!/bin/bash
CERTS_SECRETS_PATH="./secrets"

# Execute:
# ./route53-credentials-secret.sh --accesskeyid iamuseraccessid --accesssecretkey iamuseraccesssecretkey

accesskeyid=${accesskeyid:-something}
accesssecretkey=${accesssecretkey:-somethingelse}

while [ $# -gt 0 ]; do

   if [[ $1 == *"--"* ]]; then
        param="${1/--/}"
        declare "$param"="$2"
        echo "$1" "$2" # Optional to see the parameter:value result
   fi

  shift
done

kubectl create secret generic -n kube-system route53-credentials-secret --from-literal=access-key-id="${accesskeyid}" --from-literal=secret-access-key="${accesssecretkey}" --dry-run=client -o yaml | kubeseal | yq eval -P > ${CERTS_SECRETS_PATH}/route53-credentials-secret.yaml


