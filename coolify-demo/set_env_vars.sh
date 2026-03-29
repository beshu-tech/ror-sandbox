#!/bin/bash

if ! command -v jq &> /dev/null
then
		echo -e "jq is required:\n\nsudo apt-get update && sudo apt-get install jq"
		exit 1
fi

response=$(curl -s https://api.beshu.tech/list_es_versions)
pluginVersion=$(echo "$response" | jq -r '.pluginVersion')
esVersion=$(echo "$response" | jq -r '.es[0]')
kbnVersion=$(echo "$response" | jq -r '.kbn_universal[0]')

# instead of exporting, we should add .env file we'll map in docker-compose services
output_file=".env"
mkdir -p "$(dirname "$output_file")"
{
    echo "ROR_ES_VERSION=\"$pluginVersion\""
    echo "ROR_KBN_VERSION=\"$pluginVersion\""
    echo "ES_VERSION=\"$esVersion\""
    echo "KBN_VERSION=\"$kbnVersion\""
} > "$output_file"

echo "Environment variables have been written to: $output_file"
cat "$output_file"
