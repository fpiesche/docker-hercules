###
# Assemble Hercules build environment
###
FROM alpine:3.14 AS builder

# Install build dependencies.
RUN apk add --no-cache build-base git mariadb-dev pcre-dev linux-headers

# Create a build user
RUN adduser --home /home/builder --shell /bin/ash --gecos "builder" --disabled-password builder

# Copy the Hercules build script and distribution template
VOLUME /home/builder
ADD --chown=builder files/builder /home/builder/
