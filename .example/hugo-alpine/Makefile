## Current directory
DIR:=$(strip $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST)))))

##
.DEFAULT_GOAL := build
.PHONY: *

build:
	@docker build \
		--build-arg http_proxy=${http_proxy} \
		--build-arg https_proxy=${https_proxy} \
		--build-arg no_proxy=${no_proxy} \
		--build-arg DEBUG_LEVEL=DEBUG \
		--tag hugo \
		.

run:
	@$(MAKE) build
	@docker run -it --rm \
		-e http_proxy=${http_proxy} \
		-e https_proxy=${https_proxy} \
		-e no_proxy=${no_proxy} \
		hugo \
		bash

clean:
	@rm -rf $(DIR)/config
	@rm -rf $(DIR)/packages/**/pkg
	@rm -rf $(DIR)/packages/**/src
	@rm -rf $(DIR)/public
