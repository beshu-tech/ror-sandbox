#!/bin/bash -e

function greater_than_or_equal() {
  # Strip the -pre part (or any suffix starting with -) from both versions
  version_1=$(echo "$1" | sed 's/-pre.*//')
  version_2=$(echo "$2" | sed 's/-pre.*//')
  [ "$version_1" = "$(echo -e "$version_1\n$version_2" | sort -V | tail -n 1)" ];
}

if [[ -z "$ES_VERSION" ]]; then
  echo "No ES_VERSION variable is set"
  exit 1
fi

echo "Installing ES ROR from file..."
/usr/share/elasticsearch/bin/elasticsearch-plugin install --batch file:///tmp/ror.zip
ROR_VERSION=$(unzip -p /tmp/ror.zip plugin-descriptor.properties | grep -oP '^version=\K.*')

echo "Patching ES ROR $ROR_VERSION..."
if greater_than_or_equal "$ES_VERSION" "7.0.0"; then
  if greater_than_or_equal "$ROR_VERSION" "1.64.0"; then
    /usr/share/elasticsearch/jdk/bin/java -jar /usr/share/elasticsearch/plugins/readonlyrest/ror-tools.jar patch --I_UNDERSTAND_AND_ACCEPT_ES_PATCHING=yes
  else
    /usr/share/elasticsearch/jdk/bin/java -jar /usr/share/elasticsearch/plugins/readonlyrest/ror-tools.jar patch
  fi
elif greater_than_or_equal "$ES_VERSION" "6.7.0"; then
  if greater_than_or_equal "$ROR_VERSION" "1.64.0"; then
    "$JAVA_HOME"/bin/java -jar /usr/share/elasticsearch/plugins/readonlyrest/ror-tools.jar patch --I_UNDERSTAND_AND_ACCEPT_ES_PATCHING=yes
  else
    "$JAVA_HOME"/bin/java -jar /usr/share/elasticsearch/plugins/readonlyrest/ror-tools.jar patch
  fi
fi

echo "DONE!"