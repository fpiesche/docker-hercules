###
# Build Hercules
###
FROM florianpiesche/hercules-builder:latest AS builder

# Set this to "classic" or "renewal" to build the relevant server version (default: classic).
ARG HERCULES_SERVER_MODE=classic

# Set this to a YYYYMMDD date string to build a server for a specific packet version.
# Set HERCULES_PACKET_VERSION to "latest" to build the server for the packet version
# defined in the Hercules code base as the current supported version.
# As a recommended alternative, the "Noob Pack" client download available on the
# Hercules forums is using the packet version 20180418.
ARG HERCULES_PACKET_VERSION=latest

# You can pass in any further command line options for the build with the HERCULES_BUILD_OPTS
# build argument.
ARG HERCULES_BUILD_OPTS

# You can pass in a git commit reference or tag to build that specific version
ARG GIT_VERSION

# Run the build
USER builder
ENV WORKSPACE=/home/builder
ENV GIT_VERSION=${GIT_VERSION}
ENV HERCULES_PACKET_VERSION=${HERCULES_PACKET_VERSION}
ENV HERCULES_SERVER_MODE=${HERCULES_SERVER_MODE}
ENV HERCULES_BUILD_OPTS=${HERCULES_BUILD_OPTS}
RUN ["/bin/ash", "/home/builder/build-hercules.sh"]

# Copy the build archive to the host
FROM scratch AS exporter
COPY --from=builder /home/builder/*.tar.gz /