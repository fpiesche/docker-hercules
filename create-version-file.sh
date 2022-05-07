#!/bin/bash

source ${WORKSPACE}/.buildenv

echo "=== Adding build version file to distribution..."
VERSION_FILE=${BUILD_TARGET}/version_info.ini
echo "[version_info]" > ${VERSION_FILE}
echo "git_version="${GIT_VERSION} >> ${VERSION_FILE}
echo "packet_version="${HERCULES_PACKET_VERSION:-${PACKETVER_FROM_SOURCE}} >> ${VERSION_FILE}
echo "server_mode="${HERCULES_SERVER_MODE} >> ${VERSION_FILE}
echo "build_date="${BUILD_TIMESTAMP} >> ${VERSION_FILE}
echo "arch="${PLATFORM} >> ${VERSION_FILE}
