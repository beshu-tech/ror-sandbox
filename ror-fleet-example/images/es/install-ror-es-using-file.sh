#!/bin/bash -e

function greater_than_or_equal() {
  [ "$1" = "$(echo -e "$1\n$2" | sort -V | tail -n 1)" ];
}


if [[ -z "$ES_VERSION" ]]; then
  echo "No ES_VERSION variable is set"
  exit 1
fi

echo "Installing ES ROR from file..."
/usr/share/elasticsearch/bin/elasticsearch-plugin install --batch file:///tmp/ror.zip

echo "Patching ES ROR $ROR_VERSION..."
if greater_than_or_equal "$ES_VERSION" "7.0.0"; then
  /usr/share/elasticsearch/jdk/bin/java -jar /usr/share/elasticsearch/plugins/readonlyrest/ror-tools.jar patch --I_UNDERSTAND_AND_ACCEPT_ES_PATCHING yes
elif greater_than_or_equal "$ES_VERSION" "6.7.0"; then
  "$JAVA_HOME"/bin/java -jar /usr/share/elasticsearch/plugins/readonlyrest/ror-tools.jar patch --I_UNDERSTAND_AND_ACCEPT_ES_PATCHING yes
fi

echo "DONE!"