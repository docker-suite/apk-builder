# Hugo apk Builder
FROM craftdock/apk-builder as hugo_apk_builder

ENV PACKAGER "Hexosse <hexosse@gmail.com>"

COPY /package /package

RUN set -x \
    # Build apk file
    && /entrypoint abuild -r \
    # Copy the package where root can access it
    && sudo cp /packages/x86_64/hugo-0.37.1-r0.apk /tmp



# Hugo image
FROM craftdock/alpine-base

LABEL maintainer="Hexosse <hexosse@gmail.com>" \
      description="Alpine image with Hugo."

COPY --from=hugo_apk_builder /tmp/hugo-0.37.1-r0.apk /tmp/hugo-0.37.1-r0.apk

RUN \
	# Print executed commands
	set -x \
    # Update repository indexes
    && apk update \
    # Download the install script and run it
    && apk add --allow-untrusted /tmp/hugo-0.37.1-r0.apk \
	# Clear apk's cache
	&& apk-cleanup

