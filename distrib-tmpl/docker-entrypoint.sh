#!/bin/bash

DATABASE_CONFIG_FILE=/hercules/conf/global/sql_connection.conf
LOGIN_SERVER_CONFIG_FILE=/hercules/conf/import/login-server.conf
CHAR_SERVER_CONFIG_FILE=/hercules/conf/import/char-server.conf
MAP_SERVER_CONFIG_FILE=/hercules/conf/import/map-server.conf

echo "Filling database connection info in ${DATABASE_CONFIG_FILE}"
sed -i.bak -e "s/{{DATABASE_HOST}}/${DATABASE_HOST}/" ${DATABASE_CONFIG_FILE}
sed -i.bak -e "s/{{DATABASE_PORT}}/${DATABASE_PORT}/" ${DATABASE_CONFIG_FILE}
sed -i.bak -e "s/{{DATABASE_USER}}/${DATABASE_USER}/" ${DATABASE_CONFIG_FILE}
sed -i.bak -e "s/{{DATABASE_PASSWORD}}/${DATABASE_PASSWORD}/" ${DATABASE_CONFIG_FILE}
sed -i.bak -e "s/{{DATABASE_DB}}/${DATABASE_DB}/" ${DATABASE_CONFIG_FILE}

echo "Filling server info in ${CHAR_SERVER_CONFIG_FILE}"
sed -i.bak -e "s/{{SERVER_NAME}}/${SERVER_NAME}/" ${CHAR_SERVER_CONFIG_FILE}
sed -i.bak -e "s/{{WISP_SERVER_NAME}}/${WISP_SERVER_NAME}/" ${CHAR_SERVER_CONFIG_FILE}
sed -i.bak -e "s/{{INTERSERVER_USER}}/${INTERSERVER_USER}/" ${CHAR_SERVER_CONFIG_FILE}
sed -i.bak -e "s/{{INTERSERVER_PASSWORD}}/${INTERSERVER_PASSWORD}/" ${CHAR_SERVER_CONFIG_FILE}
sed -i.bak -e "s/{{LOGIN_SERVER_HOST}}/${LOGIN_SERVER_HOST}/" ${CHAR_SERVER_CONFIG_FILE}
sed -i.bak -e "s/{{CHAR_SERVER_HOST}}/${CHAR_SERVER_HOST}/" ${CHAR_SERVER_CONFIG_FILE}

echo "Filling server info in ${LOGIN_SERVER_CONFIG_FILE}"

echo "Filling server info in ${MAP_SERVER_CONFIG_FILE}"
sed -i.bak -e "s/{{INTERSERVER_USER}}/${INTERSERVER_USER}/" ${MAP_SERVER_CONFIG_FILE}
sed -i.bak -e "s/{{INTERSERVER_PASSWORD}}/${INTERSERVER_PASSWORD}/" ${MAP_SERVER_CONFIG_FILE}
sed -i.bak -e "s/{{MAP_SERVER_HOST}}/${MAP_SERVER_HOST}/" ${MAP_SERVER_CONFIG_FILE}
sed -i.bak -e "s/{{CHAR_SERVER_HOST}}/${CHAR_SERVER_HOST}/" ${MAP_SERVER_CONFIG_FILE}

/hercules/athena-start
