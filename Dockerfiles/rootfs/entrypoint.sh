#!/bin/sh

# set -e : Exit the script if any statement returns a non-true return value.
set -e

# Get and set current Alpine version
ALPINE_VERSION=`cat /etc/alpine-release`
export ALPINE_VERSION=v${ALPINE_VERSION:0:3}


# /package must contains the APKBUILD file
sudo mkdir -p /package
# /package/config must contains your public and private key
sudo mkdir -p /package/config
# /packages is where the apk files will be generated
sudo mkdir -p /packages
# Create repository
sudo mkdir -p /packages/$ALPINE_VERSION/x86_64

# Move everything from builder/.abuild home to config
[ -d "/home/builder/.abuild" ] && sudo mv -f /home/builder/.abuild/* /package/config/

# Remove .abuild folder to create symbolic link from /package/config/ to /home/builder/.abuild
sudo rm -rf /home/builder/.abuild
sudo ln -s /package/config/ /home/builder/.abuild

# Make /package and /packages belong to user builder
sudo chown -R builder:abuild /package
sudo chown -R builder:abuild /packages


# Update PACKAGER_PRIVKEY and PACKAGER_PUBKEY
export PACKAGER_PRIVKEY="/package/config/$RSA_KEY_NAME.priv"
export PACKAGER_PUBKEY="/package/config/$RSA_KEY_NAME.pub"

# Remove docker-suite keys if you provide your own key
[ "$PACKAGER_PRIVKEY" != "/package/config/docker-suite.rsa.priv" ] && sudo rm -f "/package/config/docker-suite.rsa.priv"
[ "$PACKAGER_PUBKEY" != "/package/config/docker-suite.rsa.pub" ] && sudo rm -f "/etc/apk/keys/docker-suite.rsa.pub"


#
if [  $# -ne 0 ]; then
    exec "$@"
else

    # Generate private key if needed
    if [ ! -f "$PACKAGER_PRIVKEY" ]; then
        export PACKAGER_PRIVKEY="/package/config/${RSA_KEY_NAME}.priv"
        echo "Generating private key \"${PACKAGER_PRIVKEY}\"..."
        sudo openssl genrsa -out "${PACKAGER_PRIVKEY}" 2048
    fi

    # Generate public key if needed
    if [ ! -f "$PACKAGER_PUBKEY" ] && [ ! -f "/etc/apk/keys/$(basename "$PACKAGER_PUBKEY")" ]; then
        export PACKAGER_PUBKEY="/package/config/${RSA_KEY_NAME}.pub"
        echo "Generating public key \"${PACKAGER_PUBKEY}\" from private key \"${PACKAGER_PRIVKEY}\"..."
        sudo openssl rsa -in "${PACKAGER_PRIVKEY}" -pubout -out "${PACKAGER_PUBKEY}"
    fi

    # Install public key
    [ ! -f "/etc/apk/keys/$(basename "$PACKAGER_PUBKEY")" ] && sudo cp -f "$PACKAGER_PUBKEY" /etc/apk/keys/


    # Generate abuild.conf file
    if [ ! -f "/package/config/abuild.conf" ]; then
        # Generate abuild.conf file
        # Copy file from: https://github.com/alpinelinux/abuild/blob/master/abuild.conf
        curl "https://raw.githubusercontent.com/alpinelinux/abuild/master/abuild.conf" ${HTTP_PROXY:+ -x $HTTP_PROXY} -s -L --output "/package/config/abuild.conf"
        # Change REPODEST
        sed -i -e "s|REPODEST=\$HOME/packages/|REPODEST=/packages/$ALPINE_VERSION|" /package/config/abuild.conf
        # Uncomment PACKAGER
        sed -i -e "s|#PACKAGER=\"Your Name <your@email.address>\"|PACKAGER=\"$PACKAGER\"|" /package/config/abuild.conf
        # Uncomment MAINTAINER
        sed -i -e "s|#MAINTAINER=\"\$PACKAGER\"|MAINTAINER=\"$PACKAGER\"|" /package/config/abuild.conf
        # Add PACKAGER_PRIVKEY
        echo >> /package/config/abuild.conf
        echo '# Path to your private key' >> /package/config/abuild.conf
        echo PACKAGER_PRIVKEY="\"/package/config/${RSA_KEY_NAME}.priv\"" >> /package/config/abuild.conf
    fi

    # Sign index if exist
    [ -f "/packages/$ALPINE_VERSION/x86_64/APKINDEX.tar.gz" ] && abuild-sign -k $PACKAGER_PRIVKEY -p $RSA_KEY_NAME "/packages/$ALPINE_VERSION/x86_64/APKINDEX.tar.gz"

    # Make keys belong to user builder
    sudo chown -R builder:abuild /package/config

    # APKBUILD must exist in /package
    if [ ! -s "/package/APKBUILD" ]; then
        echo "APKBUILD must exist in /package"
        exit 1
    fi

    # Generate apk
    generate.sh
fi
