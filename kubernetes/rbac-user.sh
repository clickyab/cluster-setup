#!/usr/bin/env bash
set -x
set -eo pipefail

CA_LOCATION=${HOME}/clickyab/kubeaccess/kubernetes/pki
KEY_LOCATION=${HOME}/clickyab/kubeaccess
USER_NAME=${1:-}
TEAM=${2:-devteam}
NAMESPACE=${3:-jabeh}
VALID_DAYS=${4:-60}

[ -z "$USER_NAME" ] && exit 1
mkdir -p ${KEY_LOCATION}/${USER_NAME}
pushd ${KEY_LOCATION}/${USER_NAME}
[ -f ${USER_NAME}.key ] || openssl genrsa -out ${USER_NAME}.key 2048
[ -f ${USER_NAME}.csr ] || openssl req -new -key ${USER_NAME}.key -out ${USER_NAME}.csr -subj "/CN=${USER_NAME}/O=${TEAM}"
openssl x509 -req -in ${USER_NAME}.csr -CA ${CA_LOCATION}/ca.pem -CAkey ${CA_LOCATION}/ca-key.pem -CAcreateserial -out ${USER_NAME}.crt -days ${VALID_DAYS}
cp ${CA_LOCATION}/ca.pem ${KEY_LOCATION}/${USER_NAME}

cat <<EOF >config
apiVersion: v1
clusters:
- cluster:
    certificate-authority: ca.pem
    server: https://145.239.10.114:6443
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    namespace: ${NAMESPACE}
    user: ${USER_NAME}
  name: ${USER_NAME}-context
current-context: ${USER_NAME}-context
kind: Config
preferences: {}
users:
- name: ${USER_NAME}
  user:
    client-certificate: ${USER_NAME}.crt
    client-key: ${USER_NAME}.key
EOF


