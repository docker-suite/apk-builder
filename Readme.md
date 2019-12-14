# ![](https://github.com/docker-suite/artwork/raw/master/logo/png/logo_32.png) apk-builder
[![Build Status](http://jenkins.hexocube.fr/job/docker-suite/job/apk-builder/badge/icon?color=green&style=flat-square)](http://jenkins.hexocube.fr/job/docker-suite/job/apk-builder/)
![Docker Pulls](https://img.shields.io/docker/pulls/dsuite/apk-builder.svg?style=flat-square)
![Docker Stars](https://img.shields.io/docker/stars/dsuite/apk-builder.svg?style=flat-square)
![MicroBadger Layers (tag)](https://img.shields.io/microbadger/layers/dsuite/apk-builder/latest.svg?style=flat-square)
![MicroBadger Size (tag)](https://img.shields.io/microbadger/image-size/dsuite/apk-builder/latest.svg?style=flat-square)
[![License: MIT](https://img.shields.io/badge/License-MIT-brightgreen.svg?style=flat-square)](https://opensource.org/licenses/MIT)
[![dockeri.co](https://dockeri.co/image/dsuite/apk-builder)](https://hub.docker.com/r/dsuite/apk-builder)

Build your own package for [Alpine][alpine].


## ![](https://github.com/docker-suite/artwork/raw/master/various/pin/png/pin_16.png) What is an alpine package

More infos on [Alpine][alpine] packages :
* [Creating an Alpine package](http://wiki.alpinelinux.org/wiki/Creating_an_Alpine_package)
* [APKBUILD Reference](https://wiki.alpinelinux.org/wiki/APKBUILD_Reference)
* [APKBUILD examples](https://wiki.alpinelinux.org/wiki/APKBUILD_examples)
* [Alpine Linux packages](https://pkgs.alpinelinux.org/packages)


## ![](https://github.com/docker-suite/artwork/raw/master/various/pin/png/pin_16.png) RSA keys

### Create a new key pair

Declare `RSA_KEY_NAME` environment variable with a name to give to your key and a new key pair will be generated in `/config` folder. 

### Use your own key

To use your own key, place your public and private key in `/config` folder.  
Then declare the following environment variable:
* `RSA_KEY_NAME`: This is the name given to your key (Exemple: `my-key.rsa`)  
* `PACKAGER_PRIVKEY`: Path to your private key (Exemple: `/config/my-key.rsa.priv`)
* `PACKAGER_PUBKEY`: Path to your public key (Exemple: `/config/my-key.rsa.pub`)  

Your public key is automatically copied to `/etc/apk/keys/` inside the container and to  `/public` folder.

## ![](https://github.com/docker-suite/artwork/raw/master/various/pin/png/pin_16.png) Usage
### Create your package

Create your package with an `APKBUILD` file and place it in your `packages` folder  
Run apk-builder to generate your package(s).  
The resulting apk file and signed index can be found in  `public` folder  

```bash
    docker run -t --rm \
        -v $PWD/config:/config \
        -v $PWD/packages:/packages \
        -v $PWD/public:/public \
        dsuite/apk-builder:3.10 package
```

See: [hugo-apk example][hugo-apk] for more details.

Or with an existing RSA key

```bash
    docker run \
	    -e RSA_KEY_NAME="my-key.rsa" \
        -e PACKAGER_PRIVKEY="$PWD/config/my-key.rsa.pub" \
        -e PACKAGER_PUBKEY="$PWD/config/my-key.rsa.priv" \
        -v $PWD/packages:/packages \
        -v $PWD/public:/public \
        dsuite/apk-builder:3.10 package
```

This would build the packages in your **$PWD/packages** local folder, and place the resulting packages in the **$PWD/public/v3.10/x86_64** folder.

### ![](https://github.com/docker-suite/artwork/raw/master/various/pin/png/pin_16.png) Generate new key pair:
```docker run --rm -t -e RSA_KEY_NAME="my-key.rsa" -v $PWD/config:/config dsuite/apk-builder```

## ![](https://github.com/docker-suite/artwork/raw/master/various/pin/png/pin_16.png) Examples
Two examples can be found in the [.example][example-folder] folder
* [hugo-apk][hugo-apk]: Build Hugo package from source.
* [hugo-alpine]: Create an alpine image with hugo using multistage.



[alpine]: http://alpinelinux.org/
[example-folder]: https://github.com/docker-suite/apk-builder/tree/master/.example/hugo-apk/
[hugo-apk]: https://github.com/docker-suite/apk-builder/tree/master/.example/hugo-apk/
[hugo-alpine]: https://github.com/docker-suite/apk-builder/tree/master/.example/hugo-alpine/
