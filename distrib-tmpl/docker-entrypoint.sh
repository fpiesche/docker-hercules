#!/bin/bash

HERCULES_DB_CONFIG_FILE=/hercules/conf/global/sql_connection.conf
# HERCULES_LOGIN_SERVER_CONFIG_FILE=/hercules/conf/import/login-server.conf
HERCULES_CHAR_SERVER_CONFIG_FILE=/hercules/conf/import/char-server.conf
HERCULES_MAP_SERVER_CONFIG_FILE=/hercules/conf/import/map-server.conf

echo "Filling database connection info in ${HERCULES_DB_CONFIG_FILE}"
sed -i.bak -e "s/{{DATABASE_HOST}}/${HERCULES_DB_HOST}/" ${HERCULES_DB_CONFIG_FILE}
sed -i.bak -e "s/{{DATABASE_PORT}}/${HERCULES_DB_PORT}/" ${HERCULES_DB_CONFIG_FILE}
sed -i.bak -e "s/{{DATABASE_USER}}/${HERCULES_DB_USERNAME}/" ${HERCULES_DB_CONFIG_FILE}
sed -i.bak -e "s/{{DATABASE_PASSWORD}}/${HERCULES_DB_PASSWORD}/" ${HERCULES_DB_CONFIG_FILE}
sed -i.bak -e "s/{{DATABASE_DB}}/${HERCULES_DB_NAME}/" ${HERCULES_DB_CONFIG_FILE}

echo "Filling server info in ${HERCULES_CHAR_SERVER_CONFIG_FILE}"
sed -i.bak -e "s/{{SERVER_NAME}}/${SERVER_NAME}/" ${HERCULES_CHAR_SERVER_CONFIG_FILE}
sed -i.bak -e "s/{{WISP_SERVER_NAME}}/${WISP_SERVER_NAME}/" ${HERCULES_CHAR_SERVER_CONFIG_FILE}
sed -i.bak -e "s/{{INTERSERVER_USER}}/${INTERSERVER_USER}/" ${HERCULES_CHAR_SERVER_CONFIG_FILE}
sed -i.bak -e "s/{{INTERSERVER_PASSWORD}}/${INTERSERVER_PASSWORD}/" ${HERCULES_CHAR_SERVER_CONFIG_FILE}
sed -i.bak -e "s/{{LOGIN_SERVER_HOST}}/${LOGIN_SERVER_HOST}/" ${HERCULES_CHAR_SERVER_CONFIG_FILE}
sed -i.bak -e "s/{{CHAR_SERVER_HOST}}/${CHAR_SERVER_HOST}/" ${HERCULES_CHAR_SERVER_CONFIG_FILE}

# echo "Filling server info in ${HERCULES_LOGIN_SERVER_CONFIG_FILE}"

echo "Filling server info in ${HERCULES_MAP_SERVER_CONFIG_FILE}"
sed -i.bak -e "s/{{INTERSERVER_USER}}/${INTERSERVER_USER}/" ${HERCULES_MAP_SERVER_CONFIG_FILE}
sed -i.bak -e "s/{{INTERSERVER_PASSWORD}}/${INTERSERVER_PASSWORD}/" ${HERCULES_MAP_SERVER_CONFIG_FILE}
sed -i.bak -e "s/{{MAP_SERVER_HOST}}/${MAP_SERVER_HOST}/" ${HERCULES_MAP_SERVER_CONFIG_FILE}
sed -i.bak -e "s/{{CHAR_SERVER_HOST}}/${CHAR_SERVER_HOST}/" ${HERCULES_MAP_SERVER_CONFIG_FILE}

if [[ -z $HERCULES_SERVER_EXECUTABLE ]]; then
    echo "No server executable specified, starting all servers..."
    servers=( login-server char-server map-server )
    for server in "${servers[@]}"; do
        screen -dmS "$server" -L -Logfile "/hercules/log/$server.log" "/hercules/$server"
    done
    tail -f /hercules/log/*.log
else
    echo "Starting $HERCULES_SERVER_EXECUTABLE..."
    $HERCULES_SERVER_EXECUTABLE
fi
