#!/bin/bash

# shellcheck source=/dev/null
source "${WORKSPACE}"/.buildenv

echo "=== Patching ARM version detection to make armv6 builds work"
sed -i.bak -e "s/#error Target platform currently not supported/#warning Target platform currently not supported/" "$HERCULES_SRC"/src/common/atomic.h

cd "${HERCULES_SRC}" && ./configure "${HERCULES_BUILD_OPTS}" "${MEMORY_MANAGER_PARAM}" "${SERVER_MODE_PARAM}" "${PACKETVER_PARAM}"
