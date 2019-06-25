DIR:=$(strip $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST)))))

build:
	@mkdir -p $(DIR)/packages
	@docker run -it --rm \
		-e http_proxy=${http_proxy} \
		-e https_proxy=${https_proxy} \
		-e RSA_KEY_NAME=hugo.rsa \
		-v $(DIR)/package:/package \
		-v $(DIR)/packages:/packages \
		dsuite/apk-builder:3.9

clean:
	@rm -rf $(DIR)/packages
	@rm -rf $(DIR)/package/config
	@rm -rf $(DIR)/package/pkg
	@rm -rf $(DIR)/package/src
