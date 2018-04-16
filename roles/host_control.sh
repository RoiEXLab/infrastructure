#!/bin/bash
LOBBY_DB=/root/infrastructure/roles/lobby_db/lobby_db.sh
LOBBY=/root/infrastructure/roles/lobby/lobby.sh
BOT=/root/infrastructure/roles/bot/bot.sh
PROMETHEUS=/root/infrastructure/roles/support/prometheus/prometheus.sh
GRAFANA=/root/infrastructure/roles/support/grafana/grafana.sh

set -eu
. /root/infrastructure/common.sh

#LATEST_RELEASE=$(curl -s 'https://api.github.com/repos/triplea-game/triplea/releases/latest' \
#    | python3 -c "import sys, json; print(json.load(sys.stdin)['tag_name'])")

TEMP_FILE=$(tempfile)
curl  -sq 'https://api.github.com/repos/triplea-game/triplea/tags' | \
    grep "name" > $TEMP_FILE
LATEST_BUILD=$(cat $TEMP_FILE | sed 's/.*\.//' | sed 's/".*//' | sort -nr | head -1)
LATEST_TAG=$(grep ${LATEST_BUILD} $TEMP_FILE | sed 's/.* "//' | sed 's/".*$//')

LATEST_RELEASE="1.9.0.0.10104"
PRERELEASE_LOBBY="66.175.213.79"
PRERELEASE_LOBBY_PORT="7000"

case "$(hostname)" in
  bot25_ca_usa)
    ${BOT} \
      --bot-name CA_USA \
      --bot-port 8000 \
      --bot-start-number 1 \
      --bot-count 5 \
      --max-memory 128 \
      --lobby-port ${PRERELEASE_LOBBY_PORT} \
      --lobby-host ${PRERELEASE_LOBBY} \
      --tag-name ${LATEST_RELEASE}
    ;;
  bot35_frankfurt_de)
    ${BOT} \
      --bot-name FRANKFURT_DE \
      --bot-port 8000 \
      --bot-start-number 2 \
      --bot-count 5 \
      --max-memory 128 \
      --lobby-port ${PRERELEASE_LOBBY_PORT} \
      --lobby-host ${PRERELEASE_LOBBY} \
      --tag-name ${LATEST_RELEASE}
    ;;
  bot45_atlanta_ga)
    ${BOT} \
      --bot-name FRANKFURT_DE \
      --bot-port 8000 \
      --bot-start-number 3 \
      --bot-count 5 \
      --max-memory 128 \
      --lobby-port ${PRERELEASE_LOBBY_PORT} \
      --lobby-host ${PRERELEASE_LOBBY} \
      --tag-name ${LATEST_RELEASE}
    ;;
  prerelease_staging)
    ${LOBBY_DB} \
       --database-port 5432 \
       --tag-name ${LATEST_TAG}
    ${LOBBY} \
       --lobby-port 7000 \
       --database-port 5432 \
       --tag-name ${LATEST_TAG}
    ${BOT} \
      --bot-name prerelease \
      --bot-port 8000 \
      --bot-start-number 9 \
      --bot-count 1 \
      --max-memory 128 \
      --lobby-port ${PRERELEASE_LOBBY_PORT} \
      --lobby-host ${PRERELEASE_LOBBY} \
      --tag-name ${LATEST_TAG}
    ;;
  infra-support)
    ${PROMETHEUS}
    ${GRAFANA}
    ;;
  *)
    reportError "Unknown host: $(hostname)"
  ;;
esac
