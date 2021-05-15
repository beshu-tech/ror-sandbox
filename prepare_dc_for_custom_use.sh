#!/usr/bin/env bash
 ./dc-internals/common.sh

echo $'Elasticsearch version: \e[32m'$ELASTICSEARCH_VERSION$'\e[0m'
echo ROR plugin location: $ELASTICSEARCH_LOCATION
echo $'Kibana version: \e[33m'$KIBANA_VERSION$'\e[0m'
echo ROR kibana plugin location: $KIBANA_LOCATION
echo ''
echo 'Building all images:'
echo ''

docker-compose build
