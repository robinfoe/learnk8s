.DEFAULT_GOAL := help
.PHONY: build






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

cluster.down: 
	./kind/kind-cluster.sh down