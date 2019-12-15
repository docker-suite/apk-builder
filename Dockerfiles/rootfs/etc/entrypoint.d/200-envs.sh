#!/usr/bin/env bash

# set -e : Exit the script if any statement returns a non-true return value.
# set -u : Exit the script when using uninitialised variable.
set -eu

#
# Alpine version
#
env_set "ALPINE_VERSION" "$(env_get "ALPINE_VERSION")"

#
# OS architecture
#
env_set "ALPINE_ARCH" "$(uname -m)"
