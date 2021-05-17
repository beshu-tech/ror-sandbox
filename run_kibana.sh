#!/usr/bin/env bash
. ./dc-internals/common.sh

echo $'Kibana version: \e[33m'$KIBANA_VERSION$'\e[0m'
echo ROR kibana plugin location: $KIBANA_LOCATION
echo ''

ESHOME=false

while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -e|--eshome)
    ESHOME=true
    shift # past argument
    ;;
    *)    # unknown option
    shift
esac
done

if [ $ESHOME = true ]; then
  echo "Running kibana-oss container\n"
  docker-compose build kibana-oss
  docker-compose up kibana-oss 
else 
  echo "Running kibana container\n"
  docker-compose build kibana
  docker-compose up kibana 
fi
