#! /usr/bin/env bash



set -o pipefail
set -o errexit
set -o nounset

readonly KUBECTL=${KUBECTL:-kubectl}
readonly WAITTIME=${WAITTIME:-5m}

readonly PROGNAME=$(basename "$0")

readonly HERE=$(cd $(dirname $0) && pwd)
readonly FOLDER_TEMPLATE=$(cd ${HERE}/template && pwd)
readonly FOLDER_GEN=${HERE}/gen


unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     MACHINE=Linux;;
    Darwin*)    MACHINE=Mac;;
    CYGWIN*)    MACHINE=Cygwin;;
    MINGW*)     MACHINE=MinGw;;
    *)          MACHINE="UNKNOWN:${unameOut}"
esac

if [ ${MACHINE} == Mac ]
then
   IP_ADDR=$(ipconfig getifaddr en0)
elif [ ${MACHINE} == Linux ]
then
   IP_ADDR=$(hostname -I)
else 
   echo "Please enter IP add ::"
   read IP_ADDR
fi


FQDN=opa.kind.$IP_ADDR.nip.io
ytt -v opa.fqdn=$FQDN -v opa.ip=$IP_ADDR -f $FOLDER_TEMPLATE --output-files $FOLDER_GEN

RESOURCES=(namespace.yaml cert-self-issuer.yaml certificate.yaml configmap-auth-rules.yaml opa-release.yaml ingress.yaml )


for item in "${RESOURCES[@]}"
do
    ${KUBECTL} apply -f $FOLDER_GEN/$item
done

${KUBECTL} wait --timeout="${WAITTIME}" -n opa -l app=opa deployments --for=condition=Available


