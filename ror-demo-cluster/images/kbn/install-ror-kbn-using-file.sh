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

echo "Installing KBN ROR from file..."
if verlte "7.0.0" "$KBN_VERSION"; then
  export NODE_OPTIONS="--max-old-space-size=8192" 
fi

if verlte "7.11.0" "$KBN_VERSION"; then
  /usr/share/kibana/bin/kibana-plugin install file:///tmp/ror.zip
else 
  /usr/share/kibana/bin/kibana-plugin install --allow-root file:///tmp/ror.zip
fi

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