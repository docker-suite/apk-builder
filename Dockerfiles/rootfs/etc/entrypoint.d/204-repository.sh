#!/usr/bin/env bash

# set -e : Exit the script if any statement returns a non-true return value.
# set -u : Exit the script when using uninitialised variable.
set -eu

#
# Add local folder as repository
#
echo "/public/v$ALPINE_VERSION" >> /etc/apk/repositories

#
# Sign index if exist
#
if [ -f "/public/v$ALPINE_VERSION/$ALPINE_ARCH/APKINDEX.tar.gz" ]; then
    abuild-sign -k "$PACKAGER_PRIVKEY" -p "$RSA_KEY_NAME" "/public/v$ALPINE_VERSION/$ALPINE_ARCH/APKINDEX.tar.gz"
fi
