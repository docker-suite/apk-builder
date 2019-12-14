#!/usr/bin/env bash

# set -e : Exit the script if any statement returns a non-true return value.
# set -u : Exit the script when using uninitialised variable.
set -eu

#
# Generate abuild.conf file
#
if [[ ! -f "/config/abuild.conf" ]]; then
    # Generate abuild.conf file
    # Copy file from: https://github.com/alpinelinux/abuild/blob/master/abuild.conf
    curl -s -L "https://raw.githubusercontent.com/alpinelinux/abuild/master/abuild.conf" ${HTTP_PROXY:+ -x $HTTP_PROXY} --output "/config/abuild.conf"
    # Change REPODEST
    sed -i -e "s|REPODEST=\$HOME/packages/|REPODEST=\$HOME|" /config/abuild.conf
    # Uncomment PACKAGER
    sed -i -e "s|#PACKAGER=\"Your Name <your@email.address>\"|PACKAGER=\"$PACKAGER\"|" /config/abuild.conf
    # Uncomment MAINTAINER
    sed -i -e "s|#MAINTAINER=\"\$PACKAGER\"|MAINTAINER=\"$PACKAGER\"|" /config/abuild.conf
    # Add PACKAGER_PRIVKEY
    {
        echo
        echo '# Path to the private key'
        echo PACKAGER_PRIVKEY="\"/config/${RSA_KEY_NAME}.priv\""
    } >> /config/abuild.conf
fi

#
# Force generated packages to be store in /public folder
#
ln -s "/public/v${ALPINE_VERSION}/" "/home/$USER/packages"
