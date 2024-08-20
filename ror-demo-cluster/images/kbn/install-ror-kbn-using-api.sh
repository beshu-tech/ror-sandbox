#!/bin/bash -e

function verlte() {
  [ "$1" = "$(echo -e "$1\n$2" | sort -V | head -n1)" ]
}

function vergte() {
    [ "$1" = "$(echo -e "$1\n$2" | sort -V | head -n 1)" ] || [ "$1" = "$2" ];
};

if [[ -z "$KBN_VERSION" ]]; then
  echo "No KBN_VERSION variable is set"
  exit 1
fi

if [[ -z "$ROR_VERSION" ]]; then
  echo "No ROR_VERSION variable is set"
  exit 3
fi

ROR_KBN_EDITION=""
if verlte "1.43.0" "$ROR_VERSION" && verlte "7.9.0" "$KBN_VERSION"; then
  ROR_KBN_EDITION="kbn_universal"
else
  ROR_KBN_EDITION="kbn_free"
fi

echo "Installing KBN ROR $ROR_VERSION..."
/usr/share/kibana/bin/kibana-plugin install "https://api.beshu.tech/download/kbn?esVersion=$KBN_VERSION&pluginVersion=$ROR_VERSION&edition=$ROR_KBN_EDITION&email=ror-sandbox%40readonlyrest.com"

if vergte "8.15.0" "$KBN_VERSION"; then
  echo "Patching KBN ROR $ROR_VERSION..."
  /usr/share/kibana/node/glibc-217/bin/node plugins/readonlyrestkbn/ror-tools.js patch;
elif verlte "7.9.0" "$KBN_VERSION"; then
  echo "Patching KBN ROR $ROR_VERSION..."
  /usr/share/kibana/node/bin/node plugins/readonlyrestkbn/ror-tools.js patch;
fi

if verlte "7.9.0" "$KBN_VERSION"; then
  mv /usr/share/kibana/config/ror-newplatform-kibana.yml /usr/share/kibana/config/kibana.yml
else
  mv /usr/share/kibana/config/ror-oldplatform-kibana.yml /usr/share/kibana/config/kibana.yml
  rm -rf /usr/share/kibana/optimize # for some reason we have to remove it and let kibana optimize it on startup
fi

echo "DONE!"