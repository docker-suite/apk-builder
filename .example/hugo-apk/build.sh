#!/bin/sh

# Build docker image
docker build -t hugo .

# Generate Hugo package
docker run --rm \
    -v $PWD/package:/package \
    -v $PWD/packages:/packages \
    hugo
