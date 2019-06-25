# Hugo apk Builder
FROM dsuite/apk-builder:3.9 as hugo_apk_builder

ENV RSA_KEY_NAME hugo.rsa

COPY /package /package

RUN set -x \
    # Build apk file
    && /entrypoint.sh \
    # Copy the package where root can access it
    && sudo cp -r /packages /repo

# Hugo image
FROM dsuite/alpine-base:3.9

COPY --from=hugo_apk_builder /repo /tmp/repo
COPY --from=hugo_apk_builder /etc/apk/keys /etc/apk/keys

RUN \
	# Print executed commands
	set -x \
    # Update repository indexes
    && apk update \
    # Download the install script and run it
    && apk add --repository /tmp/repo/v3.9 \
        hugo \
	# Clear apk's cache
	&& apk-cleanup

