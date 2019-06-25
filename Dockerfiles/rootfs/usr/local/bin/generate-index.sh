#!/bin/sh

# Generate index file APKINDEX.tar.gz
# Usage generate-index

# Do not continue script on errors
set -e

# cd to package folder
cd "/packages/$ALPINE_VERSION/x86_64"

# Regenerate indexes in $REPODEST
# Create APKINDEX.unsigned.tar.gz
apk index -o APKINDEX.unsigned.tar.gz *.apk --rewrite-arch x86_64

# Digitally sign the digest using the private key
openssl dgst -sha1 -sign $PACKAGER_PRIVKEY -out .SIGN.RSA.$RSA_KEY_NAME.pub APKINDEX.unsigned.tar.gz

# tar the signe file
tar -c .SIGN.RSA.$RSA_KEY_NAME.pub | abuild-tar --cut | gzip -9 > signature.tar.gz

# Generate APKINDEX file
cat signature.tar.gz APKINDEX.unsigned.tar.gz > APKINDEX.tar.gz

# Clean up
rm APKINDEX.unsigned.tar.gz signature.tar.gz .SIGN.RSA.$RSA_KEY_NAME.pub
