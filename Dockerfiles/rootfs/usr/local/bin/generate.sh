#!/bin/sh

# set -e : Exit the script if any statement returns a non-true return value.
set -e

# Update repository indexes
sudo -E apk update

# Remove temp build and install dirs
abuild clean

# Generate checksum to be included in APKBUILD
abuild checksum

# Build from APKBUILD
# -r Install missing dependencies from system repository (using sudo)
# -K Keep buildtime temp dirs and files (srcdir/pkgdir/deps)
abuild -r -K

# Generate index with trusted signature
generate-index.sh

# Remove binary packages except current version
abuild cleanoldpkg

# Regenerate index with trusted signature
generate-index.sh
