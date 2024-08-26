#!/bin/bash -e

function verlte() {
  [ "$1" = "$(echo -e "$1\n$2" | sort -V | head -n1)" ]
}

if [[ -z "$ES_VERSION" ]]; then
  echo "No ES_VERSION variable is set"
  exit 1
fi

echo "Installing ES ROR from file..."
/usr/share/elasticsearch/bin/elasticsearch-plugin install --batch file:///tmp/ror.zip

echo "Patching ES ROR $ROR_VERSION..."
if verlte "7.0.0" "$ES_VERSION"; then
  /usr/share/elasticsearch/jdk/bin/java -jar /usr/share/elasticsearch/plugins/readonlyrest/ror-tools.jar patch
elif verlte "6.7.0" "$ES_VERSION"; then
  "$JAVA_HOME"/bin/java -jar /usr/share/elasticsearch/plugins/readonlyrest/ror-tools.jar patch
fi

echo "DONE!"