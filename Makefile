## Meta data about the image
DOCKER_IMAGE=dsuite/apk-builder
DOCKER_IMAGE_CREATED=$(shell date -u +'%Y-%m-%dT%H:%M:%SZ')
DOCKER_IMAGE_REVISION=$(shell git rev-parse --short HEAD)

## Current directory
DIR:=$(strip $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST)))))

## Define the latest version
latest = 3.14

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

build-all: ## Build all versions
	@$(MAKE) clean
	@$(MAKE) build v=3.7
	@$(MAKE) build-dev v=3.7
	@$(MAKE) build v=3.8
	@$(MAKE) build-dev v=3.8
	@$(MAKE) build v=3.9
	@$(MAKE) build-dev v=3.9
	@$(MAKE) build v=3.10
	@$(MAKE) build-dev v=3.10
	@$(MAKE) build v=3.11
	@$(MAKE) build-dev v=3.11
	@$(MAKE) build v=3.12
	@$(MAKE) build-dev v=3.12
	@$(MAKE) build v=3.13
	@$(MAKE) build-dev v=3.13
	@$(MAKE) build v=3.14
	@$(MAKE) build-dev v=3.14

test-all: ## Test all versions
	$(MAKE) test v=3.7
	$(MAKE) test-dev v=3.7
	$(MAKE) test v=3.8
	$(MAKE) test-dev v=3.8
	$(MAKE) test v=3.9
	$(MAKE) test-dev v=3.9
	$(MAKE) test v=3.10
	$(MAKE) test-dev v=3.10
	$(MAKE) test v=3.11
	$(MAKE) test-dev v=3.11
	$(MAKE) test v=3.12
	$(MAKE) test-dev v=3.12
	$(MAKE) test v=3.13
	$(MAKE) test-dev v=3.13
	$(MAKE) test v=3.14
	$(MAKE) test-dev v=3.14

push-all: ## Push all versions
	$(MAKE) push v=3.7
	$(MAKE) push-dev v=3.7
	$(MAKE) push v=3.8
	$(MAKE) push-dev v=3.8
	$(MAKE) push v=3.9
	$(MAKE) push-dev v=3.9
	$(MAKE) push v=3.10
	$(MAKE) push-dev v=3.10
	$(MAKE) push v=3.11
	$(MAKE) push-dev v=3.11
	$(MAKE) push v=3.12
	$(MAKE) push-dev v=3.12
	$(MAKE) push v=3.13
	$(MAKE) push-dev v=3.13
	$(MAKE) push v=3.14
	$(MAKE) push-dev v=3.14

shell: ## Run shell ( usage : make shell v=[3.7|3.8|3.9|3.10|3.11|3.12|3.13|3.14] )
	$(eval version := $(or $(v),$(latest)))
	@mkdir -p $(DIR)/config
	@mkdir -p $(DIR)/packages
	@mkdir -p $(DIR)/public
	@docker run -it --rm \
		-e DEBUG_LEVEL=DEBUG \
		-v $(DIR)/config:/config \
		-v $(DIR)/packages:/packages \
		-v $(DIR)/public:/public \
		$(DOCKER_IMAGE)-dev:$(version) \
		bash

package: ## Build all packages ( usage : make package v=[3.7|3.8|3.9|3.10|3.11|3.12|3.13|3.14] p=[<package-name1> <package-name2>])
	$(eval version := $(or $(v),$(latest)))
	@test "$(p)"
	@mkdir -p $(DIR)/config
	@mkdir -p $(DIR)/packages
	@mkdir -p $(DIR)/public
	@docker run -it --rm \
		-e DEBUG_LEVEL=DEBUG \
		-v $(DIR)/config:/config \
		-v $(DIR)/packages:/packages \
		-v $(DIR)/public:/public \
		$(DOCKER_IMAGE)-dev:$(version) \
		bash -c "package -p \"$(p)\""

packages: ## Build all packages ( usage : make packages v=[3.7|3.8|3.9|3.10|3.11|3.12|3.13|3.14] )
	$(eval version := $(or $(v),$(latest)))
	@mkdir -p $(DIR)/config
	@mkdir -p $(DIR)/packages
	@mkdir -p $(DIR)/public
	@docker run -it --rm \
		-e DEBUG_LEVEL=DEBUG \
		-v $(DIR)/config:/config \
		-v $(DIR)/packages:/packages \
		-v $(DIR)/public:/public \
		$(DOCKER_IMAGE)-dev:$(version) \
		bash -c "package"

key: ## Generate new private and public keys
	$(eval version := $(or $(v),$(latest)))
	@mkdir -p $(DIR)/config
	@mkdir -p $(DIR)/packages
	@mkdir -p $(DIR)/public
	@docker run -it --rm \
		-e DEBUG_LEVEL=DEBUG \
		-e RSA_KEY_NAME=my-key.rsa \
		-v $(DIR)/config:/config \
		$(DOCKER_IMAGE)-dev:$(version)
		exit

remove: ## Remove all generated images
	@docker images | grep $(DOCKER_IMAGE)-dev | tr -s ' ' | cut -d ' ' -f 2 | xargs -I {} docker rmi $(DOCKER_IMAGE)-dev:{} || true
	@docker images | grep $(DOCKER_IMAGE) | tr -s ' ' | cut -d ' ' -f 2 | xargs -I {} docker rmi $(DOCKER_IMAGE):{} || true

readme: ## Generate docker hub full description
	@docker run -t --rm \
		-e DEBUG_LEVEL=DEBUG \
		-e DOCKER_USERNAME=${DOCKER_USERNAME} \
		-e DOCKER_PASSWORD=${DOCKER_PASSWORD} \
		-e DOCKER_IMAGE=${DOCKER_IMAGE} \
		-v $(DIR):/data \
		dsuite/hub-updater

build:
	$(eval version := $(or $(v),$(latest)))
	@docker run --rm \
		-e ALPINE_VERSION=$(version) \
		-e DOCKER_IMAGE_CREATED=$(DOCKER_IMAGE_CREATED) \
		-e DOCKER_IMAGE_REVISION=$(DOCKER_IMAGE_REVISION) \
		-v $(DIR)/Dockerfiles:/data \
		dsuite/alpine-data \
		bash -c "templater Dockerfile.template > Dockerfile-$(version)"
	@docker build \
		--file $(DIR)/Dockerfiles/Dockerfile-$(version) \
		--tag $(DOCKER_IMAGE):$(version) \
		$(DIR)/Dockerfiles
	@[ "$(version)" = "$(latest)" ] && docker tag $(DOCKER_IMAGE):$(version) $(DOCKER_IMAGE):latest || true

build-dev:
	$(eval version := $(or $(v),$(latest)))
	@docker run --rm \
		-e ALPINE_VERSION=$(version) \
		-e DOCKER_IMAGE_CREATED=$(DOCKER_IMAGE_CREATED) \
		-e DOCKER_IMAGE_REVISION=$(DOCKER_IMAGE_REVISION) \
		-v $(DIR)/Dockerfiles:/data \
		dsuite/alpine-data \
		bash -c "templater Dockerfile.dev.template > Dockerfile.dev-$(version)"
	@docker build \
		--file $(DIR)/Dockerfiles/Dockerfile.dev-$(version) \
		--tag $(DOCKER_IMAGE)-dev:$(version) \
		$(DIR)/Dockerfiles
	@[ "$(version)" = "$(latest)" ] && docker tag $(DOCKER_IMAGE)-dev:$(version) $(DOCKER_IMAGE)-dev:latest || true

test:
	$(eval version := $(or $(v),$(latest)))
	@GOSS_FILES_PATH=$(DIR)/tests \
	 	dgoss run $(DOCKER_IMAGE):$(version) bash -c "sleep 60"

test-dev:
	$(eval version := $(or $(v),$(latest)))
	@GOSS_FILES_PATH=$(DIR)/tests \
	 	dgoss run $(DOCKER_IMAGE)-dev:$(version) bash -c "sleep 60"

push:
	$(eval version := $(or $(v),$(latest)))
	@docker push $(DOCKER_IMAGE):$(version)
	@[ "$(version)" = "$(latest)" ] && docker push $(DOCKER_IMAGE):latest || true

push-dev:
	$(eval version := $(or $(v),$(latest)))
	@docker push $(DOCKER_IMAGE)-dev:$(version)
	@[ "$(version)" = "$(latest)" ] && docker push $(DOCKER_IMAGE)-dev:latest || true
