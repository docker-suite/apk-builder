# apk-builder

A Docker image for building apk packages for alpine.


## What is an alpine package

More infos on alpine packages :
* [Creating an Alpine package](http://wiki.alpinelinux.org/wiki/Creating_an_Alpine_package)
* [APKBUILD Reference](https://wiki.alpinelinux.org/wiki/APKBUILD_Reference)
* [APKBUILD examples](https://wiki.alpinelinux.org/wiki/APKBUILD_examples)


## Environment

* `RSA_PRIVATE_KEY`: This is the contents of your RSA private key. (optional).  
  You should use `PACKAGER_PRIVKEY` and mount your private key if not using `RSA_PRIVATE_KEY`.
* `RSA_PRIVATE_KEY_NAME`: Defaults to `key.rsa`.  
  This is the name we will set the private key file as when using `RSA_PRIVATE_KEY`.  
  The file will be written out to `/package/config/$RSA_PRIVATE_KEY_NAME`.
* `PACKAGER_PRIVKEY`: Defaults to `/package/config/$RSA_PRIVATE_KEY_NAME`.  
  This is generally used if you are bind mounting your private key instead of passing it in with `RSA_PRIVATE_KEY`.
* `PACKAGER`: This is the name of the packager used in package metadata.
  Don't forget to chage it in your package

## Usage

```bash
    docker run \
        -v $PWD/package:/package \
        -v $PWD/packages/:/packages \
        craftdock/apk-builder
```

Or with an existing RSA key

```bash
    docker run \
        -e RSA_PRIVATE_KEY="$(cat /path/to/the/key/mykey.rsa)" \
	    -e RSA_PRIVATE_KEY_NAME="mykey.rsa" \
        -v $PWD/package:/package \
        -v $PWD/packages/:/packages \
        craftdock/apk-builder
```

This would build the package in the **$PWD/package** folder, and place the resulting packages in the **$PWD/packages/x86_64** folder.

## More commands

You can use this image to run any commands :

### Generate keys:
```docker run --rm -v $PWD:/package/ssh craftdock/apk-builder abuild-keygen -a -i```

### rebuild checksums if files has changed:
```docker run --rm -v $PWD/package:/package craftdock/apk-builder abuild checksum```


## Examples
All examples can be found in the .example folder
* hugo-apk: Build Hugo package
* hugo-multistage: Create an alpine image with hugo using multistage
