DIR:=$(strip $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST)))))

build:
	@docker build \
		--build-arg http_proxy=${http_proxy} \
		--build-arg https_proxy=${https_proxy} \
		--tag hugo \
		.
