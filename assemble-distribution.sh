#!/bin/bash

# shellcheck source=/dev/null
source "${WORKSPACE}"/.buildenv

if [[ ! -d ${HERCULES_SRC} || -z ${HERCULES_SRC} ]]; then
   echo "Failed to find Hercules source path ${HERCULES_SRC}! Please set $HERCULES_SRC."
   exit 1
elif [[ -d ${BUILD_TARGET} ]]; then
   echo "Build target path ${BUILD_TARGET} already exists! Outputting to ${BUILD_TARGET}/distrib."
   BUILD_TARGET="${BUILD_TARGET}/distrib"
elif [[ -z ${BUILD_TARGET} ]]; then
   BUILD_TARGET="${WORKSPACE}/distrib"
fi

# Copy server data to distribution directory
serverdata="cache conf db log maps npc plugins save"
for path in ${serverdata}
do
   echo "=== Copying $path to distribution..."
   mkdir -p "${BUILD_TARGET}"/"$path"
   cp -r "${HERCULES_SRC}"/"$path"/* "${BUILD_TARGET}"/"$path"/
done

echo "=== Copying executables into distribution..."
cp "${HERCULES_SRC}"/athena-start "${BUILD_TARGET}"/
cp "${HERCULES_SRC}"/char-server "${BUILD_TARGET}"/
cp "${HERCULES_SRC}"/login-server "${BUILD_TARGET}"/
cp "${HERCULES_SRC}"/map-server "${BUILD_TARGET}"/

echo "=== Removing unnecessary configuration templates from distribution..."
rm -rf "${BUILD_TARGET}"/conf/import-tmpl

echo "=== Adding common SQL files to distribution..."
mkdir -p "${BUILD_TARGET}"/sql-files/upgrades
cp "${HERCULES_SRC}"/sql-files/upgrades/* "${BUILD_TARGET}"/sql-files/upgrades/
cp "${HERCULES_SRC}"/sql-files/main.sql "${BUILD_TARGET}"/sql-files/1-main.sql 
cp "${HERCULES_SRC}"/sql-files/item_db2.sql "${BUILD_TARGET}"/sql-files/5-item_db2.sql 
cp "${HERCULES_SRC}"/sql-files/mob_db2.sql "${BUILD_TARGET}"/sql-files/6-mob_db2.sql 
cp "${HERCULES_SRC}"/sql-files/mob_skill_db2.sql "${BUILD_TARGET}"/sql-files/7-mob_skill_db2.sql 
cp "${HERCULES_SRC}"/sql-files/logs.sql "${BUILD_TARGET}"/sql-files/8-logs.sql 

if [[ ${HERCULES_SERVER_MODE} == "classic" ]]; then
   echo "=== Adding Classic SQL files to distribution..."
   mkdir -p "${BUILD_TARGET}"/sql-files
   cp "${HERCULES_SRC}"/sql-files/item_db.sql "${BUILD_TARGET}"/sql-files/2-item_db.sql 
   cp "${HERCULES_SRC}"/sql-files/mob_db.sql "${BUILD_TARGET}"/sql-files/3-mob_db.sql 
   cp "${HERCULES_SRC}"/sql-files/mob_skill_db.sql "${BUILD_TARGET}"/sql-files/4-mob_skill_db.sql 
elif [[ ${HERCULES_SERVER_MODE} == "renewal" ]]; then
   echo "=== Adding Renewal SQL files to distribution..."
   mkdir -p "${BUILD_TARGET}"/sql-files
   cp "${HERCULES_SRC}"/sql-files/item_db_re.sql "${BUILD_TARGET}"/sql-files/2-item_db.sql 
   cp "${HERCULES_SRC}"/sql-files/mob_db_re.sql "${BUILD_TARGET}"/sql-files/3-mob_db.sql 
   cp "${HERCULES_SRC}"/sql-files/mob_skill_db_re.sql "${BUILD_TARGET}"/sql-files/4-mob_skill_db.sql 
else
   echo "=== ERROR: Unknown server mode ${HERCULES_SERVER_MODE}!"
   exit 1
fi

echo "=== Adding remaining files from distribution template..."
cp -r "${WORKSPACE}"/distrib-tmpl/conf "${BUILD_TARGET}"/
cp "${WORKSPACE}"/distrib-tmpl/.env "${BUILD_TARGET}"
