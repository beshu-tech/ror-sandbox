#!/bin/bash -e

if ! docker version &>/dev/null; then
  echo "No Docker found. Docker is required to run this Sandbox. See https://docs.docker.com/engine/install/"
  exit 1
fi

if ! docker compose version &>/dev/null; then
  echo "No docker compose found. It seems you have to upgrade your Docker installation. See https://docs.docker.com/engine/install/"
  exit 2
fi

if ! docker compose config > /dev/null; then
  echo "Cannot validate docker compose configuration. It seems you have to upgrade your Docker installation. See https://docs.docker.com/engine/install/"
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

./../utils/collect-info-about-ror-es-kbn.sh

echo "Starting Elasticsearch and Kibana with installed ROR plugins ..."

if [ -n "${ROR_ACTIVATION_KEY:-}" ] && [ -z "${ROR_LICENSE_EDITION:-}" ]; then
  echo "ROR_ACTIVATION_KEY detected, attempting to auto-detect ROR_LICENSE_EDITION..."
  candidate="${ROR_ACTIVATION_KEY}"

  # Enforce JWT format strictly; fail early if not a JWT
  if ! echo "$candidate" | grep -qE '^[^\.]+\.[^\.]+\.[^\.]+$'; then
    echo "ERROR: ROR_ACTIVATION_KEY is not a JWT (expected three dot-separated parts). Aborting." >&2
    exit 1
  fi

  # Require python3 for extraction helper
  if ! command -v python3 >/dev/null 2>&1; then
    echo "ERROR: python3 is required to extract license edition from ROR_ACTIVATION_KEY but was not found in PATH. Aborting." >&2
    exit 1
  fi

  # Extract edition; fail if helper cannot parse
  script="$(cd "$(dirname "$0")" >/dev/null 2>&1 && pwd)/../utils/extract_license_edition.sh"
  if [ -x "$script" ]; then
    # Run helper and capture both stdout and stderr so we can report failures
    output="$($script "$candidate" 2>&1)" || {
      rc=$?
      echo "ERROR: extract_license_edition helper failed (rc=$rc):" >&2
      echo "$output" >&2
      exit $rc
    }
    if [ -n "$output" ]; then
      export ROR_LICENSE_EDITION="$output"
      echo "Auto-detected ROR_LICENSE_EDITION=$ROR_LICENSE_EDITION"
    else
      echo "ERROR: extract_license_edition helper returned empty edition" >&2
      exit 2
    fi
  else
    echo "ERROR: extract_license_edition helper not found or not executable" >&2
    exit 1
  fi
fi

export ROR_LICENSE_EDITION="${ROR_LICENSE_EDITION:-kbn_free}"

# Build compose file list; include Keycloak profile only when ROR_ACTIVATION_KEY is set
COMPOSE_ARGS=("-f" "docker-compose.yml")
if [[ "${ROR_LICENSE_EDITION:-}" == "kbn_ent" ]]; then
  COMPOSE_ARGS+=("-f" "docker-compose.enterprise.yml")
  echo "Including docker-compose.enterprise.yml for enterprise license"
fi

docker compose "${COMPOSE_ARGS[@]}" up -d --build --wait --remove-orphans --force-recreate

docker compose logs -f > ror-cluster.log 2>&1 &

echo -e "
***********************************************************************
***                                                                 ***
***          TIME TO PLAY!!!                                        ***
***                                                                 ***
***********************************************************************
"


if [[ "${ROR_LICENSE_EDITION:-}" == "kbn_ent" ]]; then
  echo -e "You can access ROR KBN here: https://localhost:15601 (login via 'Keycloak' button; users: 'timelord:timelord', 'user1:user1').\nKeycloak admin console: http://kc.localhost:8080/auth (admin:admin)"
else
  echo -e "You can access ROR KBN here: https://localhost:15601"
fi