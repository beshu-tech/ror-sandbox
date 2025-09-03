#!/bin/bash -e

cd "$(dirname "$0")" || exit 1

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

# Call the extract helper using an explicit relative path (./../utils/...)
if output="$(./../utils/extract_license_edition.sh "${ROR_ACTIVATION_KEY}" 2>&1)"; then
  rc=0
else
  rc=$?
fi

if [ $rc -ne 0 ]; then
  echo "ERROR: Failed to extract the ROR license edition (exit code: $rc)." >&2
  echo "$output" >&2
  exit $rc
elif [ -z "$output" ]; then
  echo "ERROR: Could not determine the ROR license edition (the extract_license_edition helper returned no result)." >&2
  exit 2
else
  export ROR_LICENSE_EDITION="$output"
  echo "Auto-detected ROR_LICENSE_EDITION=$ROR_LICENSE_EDITION"
fi

echo "Starting Elasticsearch and Kibana with installed ROR plugins ..."

docker compose --profile "${ROR_LICENSE_EDITION}" up -d --build --wait --remove-orphans --force-recreate

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
    echo -e "You can access ROR KBN here: https://localhost:15601 (login via 'Keycloak' button; users: 'extUser1:extUser1', 'extUser2:extUser2').\nKeycloak admin console: http://kc.localhost:8080/admin (admin:admin)"
    ;;
  PRO|FREE)
    echo -e "You can access ROR KBN here: https://localhost:15601"
    ;;
  *)
    ;;
esac
