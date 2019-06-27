# ![](https://github.com/docker-suite/artwork/raw/master/logo/png/logo_32.png) apk-builder
[![Build Status](http://jenkins.hexocube.fr/job/docker-suite/job/apk-builder/badge/icon?color=green&style=flat-square)](http://jenkins.hexocube.fr/job/docker-suite/job/apk-builder/)
![Docker Pulls](https://img.shields.io/docker/pulls/dsuite/apk-builder.svg?style=flat-square)
![Docker Stars](https://img.shields.io/docker/stars/dsuite/apk-builder.svg?style=flat-square)
![MicroBadger Layers (tag)](https://img.shields.io/microbadger/layers/dsuite/apk-builder/latest.svg?style=flat-square)
![MicroBadger Size (tag)](https://img.shields.io/microbadger/image-size/dsuite/apk-builder/latest.svg?style=flat-square)
[![License: MIT](https://img.shields.io/badge/License-MIT-brightgreen.svg?style=flat-square)](https://opensource.org/licenses/MIT)

Build your own package for [Alpine][alpine].


## ![](https://github.com/docker-suite/artwork/raw/master/various/pin/png/pin_16.png) What is an alpine package

More infos on [Alpine][alpine] packages :
* [Creating an Alpine package](http://wiki.alpinelinux.org/wiki/Creating_an_Alpine_package)
* [APKBUILD Reference](https://wiki.alpinelinux.org/wiki/APKBUILD_Reference)
* [APKBUILD examples](https://wiki.alpinelinux.org/wiki/APKBUILD_examples)
* [Alpine Linux packages](https://pkgs.alpinelinux.org/packages)


## ![](https://github.com/docker-suite/artwork/raw/master/various/pin/png/pin_16.png) RSA keys

apk-builder embed a default public and private key used to signed the package index file.  
However you can choose to generate a new key pair or to use your own key

### Create a new key pair

* Declare `RSA_KEY_NAME` environment variable with a name to give to your key and a new key pair will be generated in `/package/config` folder. 

### Use your own key

To use your own key, place your public and private key in `/package/config` folder.  
Then declare the following environment variable:
* `RSA_KEY_NAME`: This is the name given to your key (Exemple: `my-key.rsa`)  
* `PACKAGER_PRIVKEY`: Path to your private key (Exemple: `/package/config/my-key.rsa.priv`)
* `PACKAGER_PUBKEY`: Path to your public key (Exemple: `/package/config/my-key.rsa.pub`)  
Your public key is automaticaly copied to `/etc/apk/keys/`

## ![](https://github.com/docker-suite/artwork/raw/master/various/pin/png/pin_16.png) Usage
### Create your package

Create an `APKBUILD` file and place it in your `package` folder  
Run apk-builder to generate your package.  
The resulting apk file and signed index can be found in  `packages` folder  

```bash
    docker run \
        -v $PWD/package:/package \
        -v $PWD/packages:/packages \
        dsuite/apk-builder:3.9
```

See: [hugo-apk example][hugo-apk] for more details.

Or with an existing RSA key

```bash
    docker run \
	    -e RSA_KEY_NAME="my-key.rsa" \
        -e PACKAGER_PRIVKEY="$PWD/package/config/my-key.rsa.pub" \
        -e PACKAGER_PUBKEY="$PWD/package/config/my-key.rsa.priv" \
        -v $PWD/package:/package \
        -v $PWD/packages:/packages \
        dsuite/apk-builder:3.9
```

This would build the package in your **$PWD/package** local folder, and place the resulting packages in the **$PWD/packages/v3.9/x86_64** folder.

### ![](https://github.com/docker-suite/artwork/raw/master/various/pin/png/pin_16.png) Generate new key pair:
```docker run --rm -t -v $PWD:/package/config dsuite/apk-builder abuild-keygen -n```

### ![](https://github.com/docker-suite/artwork/raw/master/various/pin/png/pin_16.png) rebuild checksums:
```docker run --rm -t -v $PWD/package:/package dsuite/apk-builder abuild checksum```


## ![](https://github.com/docker-suite/artwork/raw/master/various/pin/png/pin_16.png) Examples
Two examples can be found in the [.example][example-folder] folder
* [hugo-apk][hugo-apk]: Build Hugo package from source.
* [hugo-alpine]: Create an alpine image with hugo using multistage.



[alpine]: http://alpinelinux.org/
[example-folder]: https://github.com/docker-suite/apk-builder/tree/master/.example/hugo-apk/
[hugo-apk]: https://github.com/docker-suite/apk-builder/tree/master/.example/hugo-apk/
[hugo-alpine]: https://github.com/docker-suite/apk-builder/tree/master/.example/hugo-alpine/
