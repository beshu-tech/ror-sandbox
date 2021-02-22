. ./dc-internals/common.sh

echo $'Elasticsearch version: \e[32m'$ELASTICSEARCH_VERSION$'\e[0m'
echo ROR plugin location: $ELASTICSEARCH_LOCATION
echo ''

docker-compose build elasticsearch
docker-compose up elasticsearch 
