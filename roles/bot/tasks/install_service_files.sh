#!/bin/bash

## Sets up service and run files

. /root/infrastructure/common.sh

TAG_NAME=$1
BOT_COUNT=$2
BOT_PORT=$3
BOT_NAME=$4
INSTALL_FOLDER=$5
LOBBY_HOST=$6
LOBBY_PORT=$7

set -eu

checkArg BOT_PORT ${BOT_PORT}

BOT_FILE_ROOT="/root/infrastructure/roles/bot/files"

checkFolder ${BOT_FILE_ROOT}

function main() {
  installServiceFile ${INSTALL_FOLDER} ${BOT_NAME} ${LOBBY_HOST} ${LOBBY_PORT}
  installRunAndUninstallFiles
  createStartStopScripts ${BOT_COUNT}
}


function installServiceFile() {
  local installFolder=$1
  local botName=$2
  local lobbyHost=$3
  local lobbyPort=$4

  cat > /lib/systemd/system/triplea-bot@.service <<EOF
[Unit]
Description=TripleA Bot %i
Documentation=https://github.com/triplea-game/lobby/blob/master/README.md

[Service]
Environment=
WorkingDirectory=${installFolder}
User=triplea
ExecStart=${installFolder}/run_bot.sh --bot-port 40%i --bot-number %i --bot-name ${botName} --lobby-host ${lobbyHost} --lobby-port ${lobbyPort}
Restart=always

[Install]
WantedBy=multi-user.target

EOF

}


function installRunAndUninstallFiles() {
  cp ${BOT_FILE_ROOT}/run_bot.sh ${INSTALL_FOLDER}/
  cp ${BOT_FILE_ROOT}/uninstall_bot.sh ${INSTALL_FOLDER}/
}

function createStartStopScripts() {
  local botCount=$1

  rm -f /home/triplea/start_all /home/triplea/stop_all

  for i in $(seq -w 01 ${botCount}); do
    local botNumber=${i}
    local botPort="40${botNumber}"

    ufw allow ${botPort}

    systemctl enable triplea-bot@${botNumber}
    echo "sudo service triplea-bot@${botNumber} start" > /home/triplea/start_bot_${botNumber}
    echo "sudo service triplea-bot@${botNumber} restart" > /home/triplea/restart_bot_${botNumber}
    echo "sudo service triplea-bot@${botNumber} stop" > /home/triplea/stop_bot_${botNumber}

    echo "sudo service triplea-bot@${botNumber} start" >> /home/triplea/start_all
    echo "sudo service triplea-bot@${botNumber} stop" >> /home/triplea/stop_all
  done
  systemctl daemon-reload
  ufw reload
  chmod +x /home/triplea/stop_bot* /home/triplea/start_bot* /home/triplea/restart_bot*
  chmod +x /home/triplea/start_all /home/triplea/stop_all
}

main
systemctl daemon-reload
