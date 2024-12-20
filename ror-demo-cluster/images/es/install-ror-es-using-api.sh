#!/bin/bash -e

function greater_than_or_equal() {
  [ "$1" = "$(echo -e "$1\n$2" | sort -V | tail -n 1)" ];
}

if [[ -z "$ES_VERSION" ]]; then
  echo "No ES_VERSION variable is set"
  exit 1
fi

if [[ -z "$ROR_VERSION" ]]; then
  echo "No $ROR_VERSION variable is set"
  exit 2
fi

echo "Installing ES ROR $ROR_VERSION..."
/usr/share/elasticsearch/bin/elasticsearch-plugin install --batch "https://api.beshu.tech/download/es?esVersion=$ES_VERSION&pluginVersion=$ROR_VERSION&email=ror-sandbox%40readonlyrest.com"

echo "Patching ES ROR $ROR_VERSION..."
if greater_than_or_equal "$ES_VERSION" "7.0.0"; then
  /usr/share/elasticsearch/jdk/bin/java -jar /usr/share/elasticsearch/plugins/readonlyrest/ror-tools.jar patch
elif greater_than_or_equal "$ES_VERSION" "6.7.0"; then
  "$JAVA_HOME"/bin/java -jar /usr/share/elasticsearch/plugins/readonlyrest/ror-tools.jar patch
fi

echo "DONE!"
