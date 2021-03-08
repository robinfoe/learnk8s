#! /usr/bin/env bash


set -o pipefail
set -o errexit
set -o nounset

readonly KUBECTL=${KUBECTL:-kubectl}
readonly WAITTIME=${WAITTIME:-5m}

readonly PROGNAME=$(basename "$0")
readonly VERS=${1:-}

if [ -z "$VERS" ] ; then
        printf "Usage: %s VERSION\n" $PROGNAME
        exit 1

fi

# Install the Cert Manager version.
${KUBECTL} apply -f "https://github.com/jetstack/cert-manager/releases/download/$VERS/cert-manager.yaml"

${KUBECTL} wait --timeout="${WAITTIME}" -n cert-manager -l app=cainjector deployments --for=condition=Available
${KUBECTL} wait --timeout="${WAITTIME}" -n cert-manager -l app=webhook deployments --for=condition=Available
${KUBECTL} wait --timeout="${WAITTIME}" -n cert-manager -l app=cert-manager deployments --for=condition=Available

