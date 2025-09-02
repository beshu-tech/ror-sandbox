#!/bin/bash -e

# Change to the directory where this script is located
cd "$(dirname "$0")" || exit 1

if ! docker version &>/dev/null; then
  echo "No Docker found. Docker is required to run this Sandbox. See https://docs.docker.com/engine/install/"
  exit 1
fi

if ! docker compose version &>/dev/null; then
  echo "No docker compose found. It seems you have to upgrade your Docker installation. See https://docs.docker.com/engine/install/"
  exit 2
fi

if ! docker compose -f docker-compose.base.yml config > /dev/null; then
  echo "Invalid docker-compose.base.yml configuration."
  exit 1
fi

echo -e "

  _____                _  ____        _       _____  ______  _____ _______
 |  __ \\              | |/ __ \\      | |     |  __ \\|  ____|/ ____|__   __|
 | |__) |___  __ _  __| | |  | |_ __ | |_   _| |__) | |__  | (___    | |
 |  _  // _ \\/ _| |/ _| | |  | | '_ \\| | | | |  _  /|  __|  \\___ \\   | |
 | | \\ \\  __/ (_| | (_| | |__| | | | | | |_| | | \\ \\| |____ ____) |  | |
 |_|  \\_\\___|\\__,_|\\__,_|\\____/|_| |_|_|\\__, |_|  \\_\\______|_____/   |_|
                                         __/ |
"

./../utils/collect-info-about-ror-es-kbn.sh

# Extract edition; fail if helper cannot parse
script="$(cd "$(dirname "$0")" >/dev/null 2>&1 && pwd)/../utils/extract_license_edition.sh"
if [ -x "$script" ]; then
  output="$($script "${ROR_ACTIVATION_KEY}" 2>&1)"
  rc=$?
  if [ $rc -ne 0 ]; then
    echo "ERROR: extract_license_edition helper failed (rc=$rc):" >&2
    echo "$output" >&2
    exit $rc
  elif [ -z "$output" ]; then
    echo "ERROR: extract_license_edition helper returned empty edition" >&2
    exit 2
  else
    export ROR_LICENSE_EDITION="$output"
    echo "Auto-detected ROR_LICENSE_EDITION=$ROR_LICENSE_EDITION"
  fi
else
  echo "ERROR: extract_license_edition helper not found or not executable" >&2
  exit 1
fi

echo "Starting Elasticsearch and Kibana with installed ROR plugins ..."

# Build compose file list; include Keycloak profile only when ROR_ACTIVATION_KEY is set
COMPOSE_ARGS=("-f" "docker-compose.base.yml")

case "${ROR_LICENSE_EDITION:-}" in
  ENT)
    COMPOSE_ARGS+=("-f" "docker-compose.enterprise.yml")
    echo "Including docker-compose.enterprise.yml for enterprise license"
    ;;
  PRO)
    COMPOSE_ARGS+=("-f" "docker-compose.pro.yml")
    echo "Including docker-compose.pro.yml for pro license"
    ;;
  FREE)
    COMPOSE_ARGS+=("-f" "docker-compose.free.yml")
    echo "Including docker-compose.free.yml for free license"
    ;;
  *)
    ;;
esac

docker compose "${COMPOSE_ARGS[@]}" up -d --build --wait --remove-orphans --force-recreate

docker compose logs -f > ror-cluster.log 2>&1 &

echo -e "
***********************************************************************
***                                                                 ***
***          TIME TO PLAY!!!                                        ***
***                                                                 ***
***********************************************************************
"

case "${ROR_LICENSE_EDITION:-}" in
  ENT)
    echo -e "You can access ROR KBN here: https://localhost:15601 (login via 'Keycloak' button; users: 'extUser1:extUser1', 'extUser2:extUser2').\nKeycloak admin console: http://kc.localhost:8080/auth (admin:admin)"
    ;;
  PRO|FREE)
    echo -e "You can access ROR KBN here: https://localhost:15601"
    ;;
  *)
    ;;
esac
