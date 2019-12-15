## Name of the image
DOCKER_IMAGE=dsuite/apk-builder

## Current directory
DIR:=$(strip $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST)))))

## Define the latest version
latest = 3.10

##
.DEFAULT_GOAL := help
.PHONY: *

help:
	@printf "\033[33mUsage:\033[0m\n  make [target] [arg=\"val\"...]\n\n\033[33mTargets:\033[0m\n"
	@grep -E '^[-a-zA-Z0-9_\.\/]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[32m%-15s\033[0m %s\n", $$1, $$2}'

clean: ## Clean the workspace
	@rm -rf $(DIR)/packages/*/pkg
	@rm -rf $(DIR)/packages/*/src
	@rm -rf $(DIR)/public

build: ## Build all versions
	@$(MAKE) clean
	@$(MAKE) build-version v=3.7
	@$(MAKE) build-version v=3.8
	@$(MAKE) build-version v=3.9
	@$(MAKE) build-version v=3.10

test: ## Test all versions
	$(MAKE) test-version v=3.7
	$(MAKE) test-version v=3.8
	$(MAKE) test-version v=3.9
	$(MAKE) test-version v=3.10

push: ## Push all versions
	$(MAKE) push-version v=3.7
	$(MAKE) push-version v=3.8
	$(MAKE) push-version v=3.9
	$(MAKE) push-version v=3.10

shell: ## Run shell ( usage : make shell v="3.10" )
	$(eval version := $(or $(v),$(latest)))
	@$(MAKE) build-version v=$(version)
	@mkdir -p $(DIR)/config
	@mkdir -p $(DIR)/packages
	@mkdir -p $(DIR)/public
	@docker run -it --rm \
		-e http_proxy=${http_proxy} \
		-e https_proxy=${https_proxy} \
		-e DEBUG_LEVEL=DEBUG \
		-v $(DIR)/config:/config \
		-v $(DIR)/packages:/packages \
		-v $(DIR)/public:/public \
		$(DOCKER_IMAGE):$(version) \
		bash

package: ## Build all packages
	$(eval version := $(or $(v),$(latest)))
	@$(MAKE) build-version v=$(version)
	@mkdir -p $(DIR)/config
	@mkdir -p $(DIR)/packages
	@mkdir -p $(DIR)/public
	@docker run -it --rm \
		-e http_proxy=${http_proxy} \
		-e https_proxy=${https_proxy} \
		-e DEBUG_LEVEL=DEBUG \
		-v $(DIR)/config:/config \
		-v $(DIR)/packages:/packages \
		-v $(DIR)/public:/public \
		$(DOCKER_IMAGE):$(version) \
		bash -c "package"

key: ## Generate nex private and public keys
	$(eval version := $(or $(v),$(latest)))
	@$(MAKE) build-version v=$(version)
	@mkdir -p $(DIR)/config
	@mkdir -p $(DIR)/packages
	@mkdir -p $(DIR)/public
	@docker run -it --rm \
		-e http_proxy=${http_proxy} \
		-e https_proxy=${https_proxy} \
		-e DEBUG_LEVEL=DEBUG \
		-e RSA_KEY_NAME=my-key.rsa \
		-v $(DIR)/config:/config \
		$(DOCKER_IMAGE):$(version)
		exit

remove: ## Remove all generated images
	@docker images | grep $(DOCKER_IMAGE) | tr -s ' ' | cut -d ' ' -f 2 | xargs -I {} docker rmi $(DOCKER_IMAGE):{}

readme: ## Generate docker hub full description
	@docker run -t --rm \
		-e http_proxy=${http_proxy} \
		-e https_proxy=${https_proxy} \
		-e DEBUG_LEVEL=DEBUG \
		-e DOCKER_USERNAME=${DOCKER_USERNAME} \
		-e DOCKER_PASSWORD=${DOCKER_PASSWORD} \
		-e DOCKER_IMAGE=${DOCKER_IMAGE} \
		-v $(DIR):/data \
		dsuite/hub-updater

build-version:
	$(eval version := $(or $(v),$(latest)))
	@docker run --rm \
		-e http_proxy=${http_proxy} \
		-e https_proxy=${https_proxy} \
		-e ALPINE_VERSION=$(version) \
		-v $(DIR)/Dockerfiles:/data \
		dsuite/alpine-data \
		bash -c "templater Dockerfile.template > Dockerfile-$(version)"
	@docker build \
		--build-arg http_proxy=${http_proxy} \
		--build-arg https_proxy=${https_proxy} \
		--file $(DIR)/Dockerfiles/Dockerfile-$(version) \
		--tag $(DOCKER_IMAGE):$(version) \
		$(DIR)/Dockerfiles
	@[ "$(version)" = "$(latest)" ] && docker tag $(DOCKER_IMAGE):$(version) $(DOCKER_IMAGE):latest || true

test-version:
	$(eval version := $(or $(v),$(latest)))
	@$(MAKE) build-version v=$(version)
	@docker run --rm -t \
		-e http_proxy=${http_proxy} \
		-e https_proxy=${https_proxy} \
		-v $(DIR)/tests:/goss \
		-v /tmp:/tmp \
		-v /var/run/docker.sock:/var/run/docker.sock \
		dsuite/goss:latest \
		dgoss run --entrypoint=/goss/entrypoint.sh $(DOCKER_IMAGE):$(version)

push-version:
	$(eval version := $(or $(v),$(latest)))
	@$(MAKE) build-version v=$(version)
	@docker push $(DOCKER_IMAGE):$(version)
	@[ "$(version)" = "$(latest)" ] && docker push $(DOCKER_IMAGE):latest || true
