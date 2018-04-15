#!/bin/bash

set -eu

CLEAN="rm -rf /root/infrastructure/"
## TODO: update repo name from fork to triplea-game
CLONE="git clone https://github.com/triplea-game/infrastructure.git /root/infrastructure/"
RUN_CRON="/root/infrastructure/update_cron.sh"

sudo apt-get install -y git
crontab -l | { cat; echo "*/1 * * * * ${CLEAN}; ${CLONE}; ${RUN_CRON}"; } | crontab -
