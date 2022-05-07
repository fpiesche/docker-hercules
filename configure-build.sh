#!/bin/bash

source ${WORKSPACE}/.buildenv

if [[ ${PLATFORM} == "armel"} ]]; then
   echo "=== Building on ARMv6 - patching ARM version detection to warn to make builds work"
   sed -i.bak -e "s/#error Target platform currently not supported/#warning Target platform currently not supported/" $HERCULES_SRC/src/common/atomic.h
fi

cd ${HERCULES_SRC}
./configure ${HERCULES_BUILD_OPTS} ${MEMORY_MANAGER_PARAM} ${SERVER_MODE_PARAM} ${PACKETVER_PARAM}