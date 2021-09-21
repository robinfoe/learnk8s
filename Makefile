.DEFAULT_GOAL := help
.PHONY: build


VER_CONTOUR=release-1.13
VER_CERT_MANAGER=v1.2.0
# VER_OPA=release-3.3



#help: @ List available tasks on this project
help:
	@echo "tasks:"
	@grep -E '[a-zA-Z\.\-]+:.*?@ .*$$' $(MAKEFILE_LIST)| tr -d '#' | grep -v '{developer}' | awk 'BEGIN {FS = ":.*?@ "}; {printf "\t\033[32m%-30s\033[0m %s\n", $$1, $$2}'


#cluster.build: @ build custom kind image
cluster.build: 
	./kind/kind-cluster.sh build


#cluster.up: @ start kind cluster with 1 master and 1 worker
cluster.up: 
	./kind/kind-cluster.sh up


#cluster.down: @ start kind cluster with 1 master and 1 worker
cluster.down: 
	./kind/kind-cluster.sh down


#cluster.deploy.contour: @ deploy Contour Ingress
cluster.deploy.contour:
	./kind/asset/contour/install-contour-release.sh ${VER_CONTOUR}

#cluster.deploy.certmanager: @ deploy Cert Manager
cluster.deploy.certmanager:
	./kind/asset/cert-manager/install-cert-manager.sh ${VER_CERT_MANAGER}

#cluster.deploy.opa: @ deploy OPA 
cluster.deploy.opa:
	./kind/asset/opa/install-opa-release.sh 
	# ${VER_OPA}


#cluster.deploy.shellops: @ deploy Shell Operator with Example
cluster.deploy.shellops:
	./kind/asset/shellops/install-shellops.sh