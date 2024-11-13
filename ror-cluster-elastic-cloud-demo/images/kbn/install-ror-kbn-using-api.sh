#!/bin/bash -e

function greater_than_or_equal() {
  [ "$1" = "$(echo -e "$1\n$2" | sort -V | tail -n 1)" ];
}

if [[ -z "$KBN_VERSION" ]]; then
  echo "No KBN_VERSION variable is set"
  exit 1
fi

if [[ -z "$ROR_VERSION" ]]; then
  echo "No ROR_VERSION variable is set"
  exit 3
fi

ROR_KBN_EDITION=""
if greater_than_or_equal "$ROR_VERSION" "1.43.0"; then
  ROR_KBN_EDITION="kbn_universal"
else
  ROR_KBN_EDITION="kbn_free"
fi

echo "Installing KBN ROR $ROR_VERSION..."
/usr/share/kibana/bin/kibana-plugin install "https://api.beshu.tech/download/kbn?esVersion=$KBN_VERSION&pluginVersion=$ROR_VERSION&edition=$ROR_KBN_EDITION&email=ror-sandbox%40readonlyrest.com"
echo "Patching KBN ROR $ROR_VERSION..."
/usr/share/kibana/node/bin/node plugins/readonlyrestkbn/ror-tools.js patch
echo "DONE!"