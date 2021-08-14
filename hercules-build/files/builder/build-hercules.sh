#!/bin/sh

# Set default workspace if it hasn't been passed in
if [[ -z ${WORKSPACE} ]]; then
   WORKSPACE="/builder"
fi

HERCULES_SRC=${WORKSPACE}/hercules-src
BUILD_TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
BUILD_IDENTIFIER=hercules
ARCH=$(uname -m)
DISTRIB_PATH=${WORKSPACE}/distrib
BUILD_TARGET=${DISTRIB_PATH}/${BUILD_IDENTIFIER}

echo "=== Getting Hercules source code..."
git clone https://github.com/HerculesWS/Hercules ${HERCULES_SRC}

if [[ ! -z ${GIT_VERSION} ]]; then
   echo "=== Checking out revision ${GIT_VERSION}..."
   cd ${HERCULES_SRC}
   git checkout ${GIT_VERSION}
   cd ${WORKSPACE}
else
   echo "=== Determining current git version..."
   cd ${HERCULES_SRC}
   GIT_VERSION=$(git describe --tags --exact-match 2> /dev/null || git symbolic-ref -q --short HEAD || git rev-parse --short HEAD)
   cd ${WORKSPACE}
   echo "=== Building ${GIT_VERSION}."
fi

if [[ ${ARCH} == "armhf"} ]]; then
   echo "=== Building on ARMv6 - patching ARM version detection to make builds work"
   sed -i.bak -e "s/#error Target platform currently not supported/#warning Target platform currently not supported/" $HERCULES_SRC/src/common/atomic.h
fi

# Disable Hercules' memory manager on arm64 to stop servers crashing
# https://herc.ws/board/topic/18230-support-for-armv8-is-it-possible/#comment-96631
if [[ ${ARCH} == "aarch64" ]] && [[ ! -z ${DISABLE_MANAGER_ARM64} ]]; then
   echo "=== Building for arm64 - disabling memory manager to stop crashes."
   HERCULES_BUILD_OPTS=$HERCULES_BUILD_OPTS" --disable-manager"
fi

# Get latest packet version from source if it hasn't been passed in.
if [[ -z ${HERCULES_PACKET_VERSION} || ${HERCULES_PACKET_VERSION} == "latest" ]]; then
   echo "=== Extracting latest packet version..."
   HERCULES_PACKET_VERSION=$(cat ${HERCULES_SRC}/src/common/mmo.h | sed -n -e 's/^.*#define PACKETVER \(.*\)/\1/p')
fi
HERCULES_BUILD_OPTS=$HERCULES_BUILD_OPTS" --enable-packetver=${HERCULES_PACKET_VERSION}"

# Disable Renewal on Classic mode builds
if [[ ${HERCULES_SERVER_MODE} == "classic" ]]; then
   HERCULES_BUILD_OPTS=$HERCULES_BUILD_OPTS" --disable-renewal"
fi

# Determine output file name
BUILD_ARCHIVE=${WORKSPACE}/${BUILD_IDENTIFIER}_${GIT_VERSION}_${ARCH}.tar.gz

echo "==========================================================="
echo "=== Building Hercules version: ${GIT_VERSION}"
echo "=== Server mode: ${HERCULES_SERVER_MODE}"
echo "=== Packet version: ${HERCULES_PACKET_VERSION}"
echo "=== Target platform: ${ARCH}"
echo "==========================================================="

echo "=== Build options: ${HERCULES_BUILD_OPTS}..."

rm -rf ${BUILD_TARGET}
cd ${HERCULES_SRC}
./configure ${HERCULES_BUILD_OPTS}
if [[ $? -ne 0 ]]; then
   echo "CONFIGURE FAILED"
   exit 1
fi

make

if [[ $? -ne 0 ]]; then
   echo "BUILD FAILED"
   exit 1
fi

echo "==========================================================="
echo "=== Assembling distribution"
echo "=== Distribution target directory: ${DISTRIB_PATH}"
echo "=== Distribution archive: ${BUILD_ARCHIVE}"
echo "==========================================================="

# Copy server data to distribution directory
serverdata="cache conf db log maps npc plugins save"
for path in ${serverdata}
do
   echo "=== Copying $path to distribution..."
   mkdir -p ${BUILD_TARGET}/$path
   cp -r ${HERCULES_SRC}/$path/* ${BUILD_TARGET}/$path/
done

echo "=== Copying executables into distribution..."
cp ${HERCULES_SRC}/athena-start ${BUILD_TARGET}/
cp ${HERCULES_SRC}/char-server ${BUILD_TARGET}/
cp ${HERCULES_SRC}/login-server ${BUILD_TARGET}/
cp ${HERCULES_SRC}/map-server ${BUILD_TARGET}/

echo "=== Removing unnecessary configuration templates from distribution..."
rm -rf ${BUILD_TARGET}/conf/import-tmpl

echo "=== Adding common SQL files to distribution..."
mkdir -p ${BUILD_TARGET}/sql-files/upgrades
cp ${HERCULES_SRC}/sql-files/upgrades/* ${BUILD_TARGET}/sql-files/upgrades/
cp ${HERCULES_SRC}/sql-files/main.sql ${BUILD_TARGET}/sql-files/1-main.sql 
cp ${HERCULES_SRC}/sql-files/item_db2.sql ${BUILD_TARGET}/sql-files/5-item_db2.sql 
cp ${HERCULES_SRC}/sql-files/mob_db2.sql ${BUILD_TARGET}/sql-files/6-mob_db2.sql 
cp ${HERCULES_SRC}/sql-files/mob_skill_db2.sql ${BUILD_TARGET}/sql-files/7-mob_skill_db2.sql 
cp ${HERCULES_SRC}/sql-files/logs.sql ${BUILD_TARGET}/sql-files/8-logs.sql 

if [[ ${HERCULES_SERVER_MODE} == "classic" ]]; then
   echo "=== Adding Classic SQL files to distribution..."
   mkdir -p ${BUILD_TARGET}/sql-files
   cp ${HERCULES_SRC}/sql-files/item_db.sql ${BUILD_TARGET}/sql-files/2-item_db.sql 
   cp ${HERCULES_SRC}/sql-files/mob_db.sql ${BUILD_TARGET}/sql-files/3-mob_db.sql 
   cp ${HERCULES_SRC}/sql-files/mob_skill_db.sql ${BUILD_TARGET}/sql-files/4-mob_skill_db.sql 
elif [[ ${HERCULES_SERVER_MODE} == "renewal" ]]; then
   echo "=== Adding Renewal SQL files to distribution..."
   mkdir -p ${BUILD_TARGET}/sql-files
   cp ${HERCULES_SRC}/sql-files/item_db_re.sql ${BUILD_TARGET}/sql-files/2-item_db.sql 
   cp ${HERCULES_SRC}/sql-files/mob_db_re.sql ${BUILD_TARGET}/sql-files/3-mob_db.sql 
   cp ${HERCULES_SRC}/sql-files/mob_skill_db_re.sql ${BUILD_TARGET}/sql-files/4-mob_skill_db.sql 
else
   echo "=== ERROR: Unknown server mode ${HERCULES_SERVER_MODE}!"
   exit 1
fi

echo "=== Adding remaining files from distribution template..."
cp -r ${WORKSPACE}/distrib-tmpl/* ${DISTRIB_PATH}/
cp ${WORKSPACE}/distrib-tmpl/.env ${DISTRIB_PATH}

echo "=== Adding build version file to distribution..."
VERSION_FILE=${BUILD_TARGET}/version_info.ini
echo "[version_info]" > ${VERSION_FILE}
echo "git_version="${GIT_VERSION} >> ${VERSION_FILE}
echo "packet_version="${HERCULES_PACKET_VERSION} >> ${VERSION_FILE}
echo "server_mode="${HERCULES_SERVER_MODE} >> ${VERSION_FILE}
echo "build_date="${BUILD_TIMESTAMP} >> ${VERSION_FILE}
echo "arch="${ARCH} >> ${VERSION_FILE}

echo "=== Compressing distribution..."
tar cfz ${BUILD_ARCHIVE} ${DISTRIB_PATH}/

echo "=== Done!"
