#!/usr/bin/env bash

# set -e : Exit the script if any statement returns a non-true return value.
# set -u : Exit the script when using uninitialised variable.
set -eu

#
# /etc/apk/keys
#
if [[ ! -d "/etc/apk/keys" ]]; then
    DEBUG "Creating folder: /etc/apk/keys"
    mkdir -p /etc/apk/keys
fi
chown -R "$USER":abuild /etc/apk/keys

#
# /home/$USER/.abuild
#
if [[ ! -d "/home/$USER/.abuild" ]]; then
    DEBUG "Creating folder: /home/$USER/.abuild"
    mkdir -p "/home/$USER/.abuild"
fi
chown -R "$USER":abuild "/home/$USER/.abuild"


#
# /config :     Must contain the public and private key of
#               you repository.
#
#  example : /config/docker-suite.rsa.pub
#            /config/docker-suite.rsa.priv
#
if [[ ! -d "/config" ]]; then
    DEBUG "Creating folder: /config"
    mkdir -p "/config"
fi
chown -R "$USER":abuild /config

#
# /packages :   Must contains all packages to build
#               Each package must contain an APKBUILD file
#
#  example : /packages/composer/APKBUILD
#
if [[ ! -d "/packages" ]]; then
    DEBUG "Creating folder: /packages"
    mkdir -p "/packages"
fi
chown -R "$USER":abuild /packages

#
# /public :     This is your repository.
#
if [[ ! -d "/public" ]]; then
    DEBUG "Creating folder: /public"
    mkdir -p "/public"
fi
chown -R "$USER":abuild /public

#
# /public/{{Alpine vesion}}/{{Architecture}}
#
if [[ ! -d "/public/v$ALPINE_VERSION/$ALPINE_ARCH" ]]; then
    DEBUG "Creating folder: /public/v$ALPINE_VERSION/$ALPINE_ARCH"
    mkdir -p "/public/v$ALPINE_VERSION/$ALPINE_ARCH"
fi
chown -R "$USER":abuild "/public/v$ALPINE_VERSION/$ALPINE_ARCH"
