#!/bin/bash
ENVFILE=${WORKSPACE}/.buildenv

PLATFORM=$(uname -m)
echo PLATFORM="${PLATFORM}" >> "${ENVFILE}"
echo BUILD_TIMESTAMP="$(date +"%Y-%m-%d_%H-%M-%S")" >> "${ENVFILE}"

# Get the current release tag if present or just the short commit ID
if [[ ${HERCULES_RELEASE} != "latest" ]]; then
   GIT_VERSION=${HERCULES_RELEASE}
else
   GIT_VERSION=$(cd "${HERCULES_SRC}" && (git describe --tags --exact-match 2> /dev/null || git rev-parse --short HEAD))
fi

if [[ ${GIT_VERSION} == "" ]]; then
   echo "Failed to get git tag or commit ID for Hercules source directory!"
   exit 1
else
   echo GIT_VERSION="${GIT_VERSION}" >> "${ENVFILE}"
fi

# Disable Hercules' memory manager on arm64 to stop servers crashing
# https://herc.ws/board/topic/18230-support-for-armv8-is-it-possible/#comment-96631
if [[ ${PLATFORM} == "aarch64" ]] && [[ -n ${DISABLE_MANAGER_ARM64} ]]; then
   echo MEMORY_MANAGER_PARAM="--disable-manager" >> "${ENVFILE}"
fi

# Set packet version either to ${HERCULES_PACKET_VERSIN} or what's defined in src/common/mmo.h as current.
if [[ -n "${HERCULES_PACKET_VERSION}" && ${HERCULES_PACKET_VERSION} != "latest" ]]; then
   echo PACKETVER_PARAM="--enable-packetver=${HERCULES_PACKET_VERSION}" >> "${ENVFILE}"
else
   PACKETVER_FROM_SOURCE=$(sed -n -e 's/^.*#define PACKETVER \(.*\)/\1/p' "${HERCULES_SRC}"/src/common/mmo.h)
   echo PACKETVER_PARAM="--enable-packetver=${PACKETVER_FROM_SOURCE}" >> "${ENVFILE}"
fi

# If classic mode is specified, add the --disable-renewal build option
if [[ ${HERCULES_SERVER_MODE} == "classic" ]]; then
   echo SERVER_MODE_PARAM="--disable-renewal" >> "${ENVFILE}"
elif [[ ${HERCULES_SERVER_MODE} != "renewal" ]]; then
   echo "Unknown server mode: ${HERCULES_SERVER_MODE}! Valid options are classic or renewal."
   exit 1
fi
