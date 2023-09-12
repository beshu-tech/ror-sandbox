#!/bin/bash -e

function verlte() {
  [ "$1" = "`echo -e "$1\n$2" | sort -V | head -n1`" ]
}

if [[ -z "$KBN_VERSION" ]]; then
  echo "No KBN_VERSION variable is set"
  exit 1
fi

echo "Installing KBN ROR from file..."
/usr/share/kibana/bin/kibana-plugin install file:///tmp/ror.zip
if verlte "7.9.0" "$KBN_VERSION"; then
  echo "Patching KBN ROR $ROR_VERSION..."
  /usr/share/kibana/node/bin/node plugins/readonlyrestkbn/ror-tools.js patch
fi
echo "DONE!"