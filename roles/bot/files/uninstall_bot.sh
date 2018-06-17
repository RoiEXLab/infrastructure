#!/bin/bash

if [[ $USER != "root" ]]; then
  echo "This script must be run as root"
  echo "Type 'sudo $0'"
  exit 1
fi

if ! [[ -f "$(dirname $0)/version" ]]; then
  echo "Wrong directory, a version file was not found. You need to execute this script inside of your installation directory. Default: /home/triplea/bots"
  exit 1
fi

echo "This will remove all files of your bot-installation"
read -p "Are you sure you want to continue? (y/N)" -r
if [[ $REPLY =~ ^[Yy]$ || $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
  SERVICE_FILE="/lib/systemd/system/triplea-bot@.service"
  if [[ -f "$SERVICE_FILE" ]]; then
    service 'triplea-bot@*' stop
    # Clean up service file remainders
    systemctl reset-failed triplea-bot@*.service

    # Disable all bots that were ever active on this machine
    # The regex below strips the bot number from the active service names
    # i.e. triplea-bot@12.service -> 12
    local installedUnits=$(systemctl list-units triplea-bot@*.service --all --no-legend | grep -Po "(?<=^triplea-bot@)\d+(?=\.service)")
    for botNumber in installedUnits; do
      systemctl disable triplea-bot@$botNumber
    done
    rm $SERVICE_FILE
  fi
  rm "$0"
  DIR=$(dirname $0)
  if [[ $DIR -ef $PWD ]]; then
    DIR=$PWD
    cd ..
  fi
  rm -r "$DIR"
fi

echo "The triplea bot software was successfully removed from your computer"
echo "The triplea user still exists. Run 'deluser --remove-home triplea' to remove this user"
echo "Be aware, that this user is also used by the lobby software"
