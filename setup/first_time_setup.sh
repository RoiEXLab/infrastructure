#!/bin/bash

set -e

NEW_HOST_NAME=$1
PAPERTRAIL_TOKEN=$2

if [ -z "${PAPERTRAIL_TOKEN}" ]; then
  echo "error, paper trail token needs to be specified"
  exit 1
fi


function oneTimeSetupMain() {
  setHostName ${NEW_HOST_NAME}
  addPaperTrailToken ${PAPERTRAIL_TOKEN}
  installCrontab
  enforceSshKeysOnly
}

function setHostName() {
  local newHostName=$1

  if [ -z "${newHostName}" ]; then
    echo "Need to supply host name as argument"
    echo "usage: $(basename $0) hostname"
    exit 1
  fi

  echo "${newHostName}" > /etc/hostname
  sed -i "s/^\(127.0.0.1.*\)localhost$/\1 ${newHostName} localhost/" /etc/hosts
}

function addPaperTrailToken() {
  local paperTrailToken=$1
  mkdir -p /home/triplea
  echo "papertrail_token=${paperTrailToken}" > /home/triplea/secrets
}


function installCrontab() {
  local clean="rm -rf /root/infrastructure/"
  local clone="git clone https://github.com/triplea-game/infrastructure.git /root/infrastructure/"
  local runCron="/root/infrastructure/update_cron.sh"

  sudo apt-get install -y git
  crontab -l | { cat; echo "*/5 * * * * ${clean}; ${clone}; ${runCron}"; } | crontab -
}

function enforceSshKeysOnly() {
  # turn off password logins, SSH keys only
  local sshConf="/etc/ssh/sshd_config"
  sed -i 's/ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/' ${sshConf}
  sed -i 's/PasswordAuthentication.*/PasswordAuthentication no/' ${sshConf}
  sed -i 's/UsePAM.*/UsePAM no/' ${sshConf}
  sed -i 's/PermitRootLogin.*/PermitRootLogin no/' ${sshConf}
  systemctl reload ssh
}

oneTimeSetupMain
