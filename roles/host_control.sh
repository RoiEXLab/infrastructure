#!/bin/bash
LOBBY_DB=/root/infrastructure/roles/lobby_db/lobby_db.sh
LOBBY=/root/infrastructure/roles/lobby/lobby.sh
BOT=/root/infrastructure/roles/bot/bot.sh
PROMETHEUS=/root/infrastructure/roles/support/prometheus/prometheus.sh
GRAFANA=/root/infrastructure/roles/support/grafana/grafana.sh

set -eux

#LATEST_RELEASE=$(curl -s 'https://api.github.com/repos/triplea-game/triplea/releases/latest' \
#    | python3 -c "import sys, json; print(json.load(sys.stdin)['tag_name'])")

TEMP_FILE=$(tempfile)
curl  -sq 'https://api.github.com/repos/triplea-game/triplea/tags' | \
    grep "name" > $TEMP_FILE
LATEST_BUILD=$(cat $TEMP_FILE | sed 's/.*\.//' | sed 's/".*//' | sort -nr | head -1)
LATEST_TAG=$(grep ${LATEST_BUILD} $TEMP_FILE | sed 's/.* "//' | sed 's/".*$//')


case "$(hostname)" in
  prerelease_staging)
    ${LOBBY_DB} --port=5432 --tag-name=${LATEST_TAG}
    ${LOBBY} --lobby-port 7000 --database-port 5000 --tag-name ${LATEST_TAG}
    ${BOT} --start_port 8000 --count 2 --lobby-port 7000 --tag-name ${LATEST_TAG}
    ;;
  infra-support)
    ${PROMETHEUS}
    ${GRAFANA}
    ;;
  *)
    reportError "Unknown host: $(hostname)"
  ;;
esac
