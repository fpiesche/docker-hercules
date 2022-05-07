#!/bin/bash

# shellcheck source=/dev/null
source "${WORKSPACE}"/.buildenv

echo "=== Adding build version file to distribution..."
VERSION_FILE="${BUILD_TARGET}"/version_info.ini
{
    echo "[version_info]"
    echo "git_version=${GIT_VERSION}"
    echo "packet_version=${HERCULES_PACKET_VERSION:-${PACKETVER_FROM_SOURCE}}"
    echo "server_mode=${HERCULES_SERVER_MODE}"
    echo "build_date=${BUILD_TIMESTAMP}"
    echo "arch=${PLATFORM}"
} > "${VERSION_FILE}"
