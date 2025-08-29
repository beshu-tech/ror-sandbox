#!/bin/bash -e

if ! docker version &>/dev/null; then
  echo "No Docker found. Docker is required to run this Sandbox. See https://docs.docker.com/engine/install/"
  exit 1
fi

if ! docker compose version &>/dev/null; then
  echo "No docker compose found. It seems you have to upgrade your Docker installation. See https://docs.docker.com/engine/install/"
  exit 2
fi

# validate base compose file
if ! docker compose -f docker-compose.yml config > /dev/null; then
  echo "Cannot validate base docker-compose.yml."
  exit 3
fi

echo -e "

  _____                _  ____        _       _____  ______  _____ _______
 |  __ \              | |/ __ \      | |     |  __ \|  ____|/ ____|__   __|
 | |__) |___  __ _  __| | |  | |_ __ | |_   _| |__) | |__  | (___    | |
 |  _  // _ \/ _| |/ _| | |  | | '_ \| | | | |  _  /|  __|  \___ \   | |
 | | \ \  __/ (_| | (_| | |__| | | | | | |_| | | \ \| |____ ____) |  | |
 |_|  \_\___|\__,_|\__,_|\____/|_| |_|_|\__, |_|  \_\______|_____/   |_|
                                         __/ |
"

./../utils/collect-info-about-ror-es-kbn.sh || true

echo "Starting Elasticsearch and Kibana with installed ROR plugins ..."

# Build compose file list; include Keycloak override only when ROR_ACTIVATION_KEY is set
COMPOSE_ARGS=("-f" "docker-compose.yml")
if [ -n "${ROR_ACTIVATION_KEY:-}" ]; then
  if [ -f docker-compose.enterprise.yml ]; then
    COMPOSE_ARGS+=("-f" "docker-compose.enterprise.yml")
    echo "Including docker-compose.enterprise.yml"
  fi
fi

# Run docker compose with selected files
docker compose "${COMPOSE_ARGS[@]}" up -d --build --wait --remove-orphans --force-recreate

docker compose logs -f > ror-cluster.log 2>&1 &

echo -e "
***********************************************************************
***                                                                 ***
***          TIME TO PLAY!!!                                        ***
***                                                                 ***
***********************************************************************
"


if [ -n "${ROR_ACTIVATION_KEY:-}" ]; then
  echo -e "You can access ROR KBN here: https://localhost:15601 (login via 'Keycloak' button; users: 'timelord:timelord', 'user1:user1').\nKeycloak admin console: http://localhost:8080/auth (admin:admin)"
else
  echo -e "You can access ROR KBN here: https://localhost:15601"
fi