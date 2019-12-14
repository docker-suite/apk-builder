#!/usr/bin/env bash

# set -e : Exit the script if any statement returns a non-true return value.
# set -u : Exit the script when using uninitialised variable.
set -eu

#
# Move everything from /home/packager/.abuild to /config
#
if [[ -d "/home/$USER/.abuild" ]] && [[ -n "$(ls -A -- "/home/$USER/.abuild")" ]]; then
    mv -vf "/home/$USER/.abuild"/* "/config"
fi

#
# Remove .abuild folder to create symlink from /config to /home/packager/.abuild
#
rm -rf "/home/$USER/.abuild"
ln -s "/config/" "/home/$USER/.abuild"

#
# Update PACKAGER_PRIVKEY and PACKAGER_PUBKEY
#
RSA_KEY_NAME="$(env_get "RSA_KEY_NAME")"
PACKAGER_PRIVKEY="/config/$RSA_KEY_NAME.priv"
PACKAGER_PUBKEY="/config/$RSA_KEY_NAME.pub"

#
# Remove docker-suite keys if an other key is provided
#
[[ ! "$PACKAGER_PRIVKEY" = "/config/docker-suite.rsa.priv" ]] && rm -f "/config/docker-suite.rsa.priv"
[[ ! "$PACKAGER_PUBKEY" = "/config/docker-suite.rsa.pub" ]] && rm -f "/etc/apk/keys/docker-suite.rsa.pub"

#
# Generate new private key if needed
#
if [[ ! -f "$PACKAGER_PRIVKEY" ]]; then
    NOTICE "Generating private key \"${PACKAGER_PRIVKEY}\"..."
    openssl genrsa -out "${PACKAGER_PRIVKEY}" 4096
    chown "$USER:abuild" "${PACKAGER_PRIVKEY}"
fi

#
# Generate new public key if needed
#
if [[ ! -f "$PACKAGER_PUBKEY" ]] && [[ ! -f "/etc/apk/keys/$(basename "$PACKAGER_PUBKEY")" ]]; then
    NOTICE "Generating public key \"${PACKAGER_PUBKEY}\" from private key \"${PACKAGER_PRIVKEY}\"..."
    openssl rsa -in "${PACKAGER_PRIVKEY}" -pubout -out "${PACKAGER_PUBKEY}"
    chown "$USER:abuild" "${PACKAGER_PUBKEY}"
fi

#
# Install the public key
#
if [[ ! -f "/etc/apk/keys/$(basename "$PACKAGER_PUBKEY")" ]]; then
    cp -f "$PACKAGER_PUBKEY" /etc/apk/keys
fi

#
# Copy the public key to /public
#
if [[ ! -f "/public/$(basename "$PACKAGER_PUBKEY")" ]]; then
    cp -f "$PACKAGER_PUBKEY" /public
fi
