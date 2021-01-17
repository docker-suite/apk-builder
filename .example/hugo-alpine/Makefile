## Current directory
DIR:=$(strip $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST)))))

##
.DEFAULT_GOAL := build
.PHONY: *

build:
	@docker build --tag hugo .

run:
	@docker run -it --rm hugo bash

clean:
	@rm -rf $(DIR)/config
	@rm -rf $(DIR)/packages/**/pkg
	@rm -rf $(DIR)/packages/**/src
	@rm -rf $(DIR)/public
