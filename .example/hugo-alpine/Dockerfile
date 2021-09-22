# Hugo apk Builder
FROM dsuite/apk-builder:3.14 as hugo_apk_builder

ENV RSA_KEY_NAME hugo.rsa

COPY /packages /packages

RUN set -x \
    # Build apk file
    && USER=packager /entrypoint.sh package \
    # Copy the package where root can access it
    && cp -r /public /repo

# Hugo image
FROM dsuite/alpine-base:3.14

## Copy hugo package
COPY --from=hugo_apk_builder /repo /tmp/repo
COPY --from=hugo_apk_builder /etc/apk/keys /etc/apk/keys

## Copy files
COPY rootfs /

RUN \
	# Print executed commands
	set -x \
    # Update repository indexes
    && apk-update \
    # Download the install script and run it
    && apk add --repository /tmp/repo/v3.14 \
        hugo \
	# Clear apk's cache
	&& apk-cleanup

