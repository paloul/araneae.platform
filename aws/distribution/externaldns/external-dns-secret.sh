#!/bin/bash
SECRETS_PATH="./secrets"

# Execute:
# ./external-dns-secret.sh --accesskeyid iamuseraccessid --accesssecretkey iamuseraccesssecretkey

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

# Write the content to the credentials variable
read -r -d '' credentials << EOM

[default]
aws_access_key_id = "${accesskeyid}"
aws_secret_access_key = ${accesssecretkey}
EOM

# Sanity check
#echo "${credentials}" # Need the quotes around variable to get new lines

#kubectl create secret generic -n kube-system external-dns --from-literal=credentials="${credentials}" --dry-run=client -o yaml
kubectl create secret generic -n kube-system external-dns --from-literal=credentials="${credentials}" --dry-run=client -o yaml | kubeseal | yq eval -P > ${SECRETS_PATH}/external-dns.yaml


