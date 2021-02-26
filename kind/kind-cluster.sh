#! /usr/bin/env bash


set -o pipefail
set -o errexit
set -o nounset

readonly KIND=${KIND:-kind}
readonly KUBECTL=${KUBECTL:-kubectl}

readonly CLUSTERNAME=${CLUSTERNAME:-learnk8s}
readonly WAITTIME=${WAITTIME:-5m}

readonly HERE=$(cd "$(dirname "$0")" && pwd)
readonly REPO=$(cd "${HERE}/.." && pwd)

readonly KIND_IMAGE="kindest/node:v1.19.1-learnk8s"


kind::cluster::exists() {
    ${KIND} get clusters | grep -q "$1"
}

kind::cluster::create() {
    ${KIND} create cluster \
        --name "${CLUSTERNAME}" \
        --wait "${WAITTIME}" \
        --config "${REPO}/kind/kind-config.yaml" \
        --image "${KIND_IMAGE}" 
}

kind::cluster::delete() {
    ${KIND}  delete  clusters ${CLUSTERNAME} 
}

kind::cluster::load() {
    ${KIND} load docker-image \
        --name "${CLUSTERNAME}" \
        "$@"
}


kind::command::up(){

    if kind::cluster::exists "$CLUSTERNAME" ; then
        echo "cluster $CLUSTERNAME already exists"
        echo exit 2
    fi

    # Create a fresh kind cluster.
    if ! kind::cluster::exists "$CLUSTERNAME" ; then
        kind::cluster::create
    fi

}


kind::command::down(){

    if kind::cluster::exists "$CLUSTERNAME" ; then
        echo "cluster $CLUSTERNAME  exists, removing cluster.... "
        kind::cluster::delete
    fi

}

kind::command::build(){

    docker build -t $KIND_IMAGE -f "${REPO}/kind/Dockerfile" .

}

kind::command::$1





# # Push test images into the cluster.
# for i in $(find "$HERE" -name "*.yaml" -print0 | xargs -0 awk '$1=="image:"{print $2}')
# do
#     docker pull "$i"
#     kind::cluster::load "$i"
# done

# # Install cert-manager.
# ${KUBECTL} apply -f https://github.com/jetstack/cert-manager/releases/download/v1.1.0/cert-manager.yaml
# ${KUBECTL} wait --timeout="${WAITTIME}" -n cert-manager -l app=cert-manager deployments --for=condition=Available
# ${KUBECTL} wait --timeout="${WAITTIME}" -n cert-manager -l app=webhook deployments --for=condition=Available
