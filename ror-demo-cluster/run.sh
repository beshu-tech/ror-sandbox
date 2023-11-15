#!/bin/bash -ex

if ! command -v docker-compose > /dev/null; then
  echo "The script require docker-compose to be installed on your machine."
  exit 1
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

source ../utils/collect-info-about-ror-es-kbn.sh

echo "Starting Elasticsearch and Kibana with installed ROR plugins ..."

docker-compose up -d --build --remove-orphans --force-recreate
docker-compose logs -f > ror-cluster.log 2>&1 &

echo -e "
***********************************************************************
***                                                                 ***
***          TIME TO PLAY!!!                                        ***
***                                                                 ***
***********************************************************************
"

echo -e "You can access ROR KBN here: http://localhost:15601 (regular user: 'user1:test' or admin user: 'admin:admin')"
