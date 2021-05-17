source ./conf/env_configuration

export ELASTICSEARCH_VERSION
export KIBANA_VERSION

if [ -z "$CUSTOM_ROR_ELASTICSEARCH_LOCATION" ]; then
  export ELASTICSEARCH_LOCATION="https://api.beshu.tech/download/es?esVersion=$ELASTICSEARCH_VERSION"
else
  export ELASTICSEARCH_LOCATION="$CUSTOM_ROR_ELASTICSEARCH_LOCATION"
fi

if [ -z "$CUSTOM_ROR_KIBANA_LOCATION" ]; then
  export KIBANA_LOCATION="https://api.beshu.tech/download/trial?esVersion=$ELASTICSEARCH_VERSION"
else
  export KIBANA_LOCATION=$CUSTOM_ROR_KIBANA_LOCATION
fi

case $USING_DOCKER_FOR_MAC_OR_WINDOWS in
  y|yes|t|true|1) export KIBANA_OSS_ELASTICSEARCH_ADDRESS=host.docker.internal:9200 ;;
  n|no|f|false|0) export KIBANA_OSS_ELASTICSEARCH_ADDRESS=172.17.0.1:9200 ;;
  *) echo $'\e[91mInvalid value of USING_DOCKER_FOR_MAC_OR_WINDOWS variable\e[0m';;
esac

export COMPOSE_FILE=./dc-internals/docker-compose.yml
export COMPOSE_PROJECT_NAME=ror-sandbox
