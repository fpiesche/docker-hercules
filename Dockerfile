###
# STAGE 1: BUILD HERCULES
# We'll build Hercules on Debian Bullseye's "slim" image.
# This minimises dependencies and download times for the builder.
###
FROM debian:bullseye-slim AS build_hercules

# Set this to "classic" or "renewal" to build the relevant server version (default: classic).
ARG HERCULES_SERVER_MODE=classic

# Set this to a YYYYMMDD date string to build a server for a specific packet version.
# Set HERCULES_PACKET_VERSION to "latest" to build the server for the packet version
# defined in the Hercules code base as the current supported version.
# As a recommended alternative, the "Noob Pack" client download available on the
# Hercules forums is using the packet version 20180418.
ARG HERCULES_PACKET_VERSION=latest

# The version of Hercules to build.
ARG HERCULES_RELEASE="latest"

# You can pass in any further command line options for the build with the HERCULES_BUILD_OPTS
# build argument.
ARG HERCULES_BUILD_OPTS

# Install build dependencies.
RUN apt-get update && apt-get install -y --no-install-recommends \
  gcc \
  git \
  libmariadb-dev \
  libmariadb-dev-compat \
  libpcre3-dev \
  libssl-dev \
  make \
  zlib1g-dev

# Create a build user
RUN adduser --home /home/builduser --shell /bin/bash --gecos "builduser" --disabled-password builduser

# Copy the repo into the build container
COPY --chown=builduser . /home/builduser

# Run the build
USER builduser
ENV WORKSPACE=/home/builduser  HERCULES_SRC=/home/builduser/hercules DISABLE_MANAGER_ARM64=true \
    HERCULES_RELEASE=${HERCULES_RELEASE} HERCULES_PACKET_VERSION=${HERCULES_PACKET_VERSION} \
    HERCULES_SERVER_MODE=${HERCULES_SERVER_MODE} HERCULES_BUILD_OPTS=${HERCULES_BUILD_OPTS} \
    BUILD_IDENTIFIER=hercules
ENV DISTRIB_PATH=${WORKSPACE}/distrib
ENV BUILD_TARGET=${DISTRIB_PATH}/${BUILD_IDENTIFIER}

WORKDIR /home/builduser
RUN ${WORKSPACE}/create-env-file.sh
RUN ${WORKSPACE}/configure-build.sh
RUN cd ${HERCULES_SRC} && make
RUN ${WORKSPACE}/assemble-distribution.sh
RUN ${WORKSPACE}/create-version-file.sh

###
# STAGE 2: EXPORT BUILD
# Here, we just copy the build into an empty Docker image so that it
# can be easily exported, e.g. to a tarball.
###

FROM scratch as export_build
COPY --from=build_hercules /home/builduser/distrib/ /

###
# STAGE 3: BUILD IMAGE
# Here, we pick a clean minimal base image, install what dependencies
# we do need and then copy the build artifact from the build stage
# into it. Doing this as a separate stage from the build minimises
# final image size.
###

FROM debian:bullseye-slim AS build_image

# Install base system dependencies and create user.
RUN \
  apt-get update && \
  apt-get install -y --no-install-recommends \
  libmariadb3 \
  libmariadb-dev-compat \
  && rm -rf /var/lib/apt/lists/*
RUN useradd --no-log-init -r hercules

# Copy the actual distribution from builder image
COPY --from=build_hercules --chown=hercules /home/builduser/distrib/ /

# Login server, Character server, Map server
EXPOSE 6900 6121 5121

# Environment variables
ENV HERCULES_DB_HOST=db HERCULES_DB_PORT=3306 HERCULES_DB_USERNAME=ragnarok HERCULES_DB_PASSWORD=ragnarok \
    HERCULES_DB_NAME=ragnarok HERCULES_SERVER_NAME="Ragnarok Online" WISP_SERVER_NAME="RagnarokOnline" \
    HERCULES_INTERSERVER_USER="wisp" HERCULES_INTERSERVER_PASSWORD="wisp" HERCULES_LOGIN_SERVER_HOST="localhost" \
    HERCULES_MAP_SERVER_HOST="localhost" HERCULES_CHAR_SERVER_HOST="localhost"

USER hercules
WORKDIR /hercules
VOLUME /hercules/conf/import
CMD [ "/hercules/docker-entrypoint.sh" ]
