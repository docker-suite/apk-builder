## Current directory
DIR:=$(strip $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST)))))

##
.DEFAULT_GOAL := package
.PHONY: *

package:
	@mkdir -p $(DIR)/config
	@mkdir -p $(DIR)/packages
	@mkdir -p $(DIR)/public
	@docker run -it --rm \
		-e RSA_KEY_NAME=hugo.rsa \
		-v $(DIR)/config:/config \
		-v $(DIR)/packages:/packages \
		-v $(DIR)/public:/public \
		dsuite/apk-builder:3.14 \
		bash -c "package"

clean:
	@rm -rf $(DIR)/config
	@rm -rf $(DIR)/packages/**/pkg
	@rm -rf $(DIR)/packages/**/src
	@rm -rf $(DIR)/public
