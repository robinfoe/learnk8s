#! /usr/bin/env bash



set -o pipefail
set -o errexit
set -o nounset

readonly KUBECTL=${KUBECTL:-kubectl}
readonly WAITTIME=${WAITTIME:-5m}

readonly PROGNAME=$(basename "$0")

readonly HERE=$(cd $(dirname $0) && pwd)
readonly FOLDER_CONFIG=${HERE}/config

RESOURCES=(namespace.yaml rbac.yaml configmap.yaml deployment.yaml dummy-app.yaml )

for item in "${RESOURCES[@]}"
do
    ${KUBECTL} apply -f $FOLDER_CONFIG/$item
done


