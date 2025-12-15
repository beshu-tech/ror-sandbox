#!/bin/bash
set -euo pipefail

# Function to replace or prepend server.name in a YAML file
_replace_server_name_in_file() {
  local cfg_file="$1"
  local name="$2"
  [ -f "$cfg_file" ] || return 0
  if grep -qE '^server\.name:' "$cfg_file"; then
    sed -i.bak "s/^server\.name:.*/server.name: ${name}/" "$cfg_file" || true
  else
    printf 'server.name: %s\n' "${name}" | cat - "$cfg_file" > "$cfg_file".tmp && mv "$cfg_file".tmp "$cfg_file"
  fi
}

# Inject SERVER_NAME into Kibana config if provided
if [ -n "${SERVER_NAME:-}" ]; then
  # Primary runtime config (kibana.yml)
  cfg="/usr/share/kibana/config/kibana.yml"
  if [ ! -f "$cfg" ]; then
    touch "$cfg"
  fi
  _replace_server_name_in_file "$cfg" "${SERVER_NAME}"

  # Also update template configs so source templates include server.name
  for tmpl in \
    /usr/share/kibana/config/enterprise-ror-newplatform-kibana.yml \
    /usr/share/kibana/config/pro-ror-newplatform-kibana.yml \
    /usr/share/kibana/config/free-ror-newplatform-kibana.yml; do
    _replace_server_name_in_file "$tmpl" "${SERVER_NAME}"
  done
fi

# Exec original CMD
if [ $# -gt 0 ]; then
  exec "$@"
else
  # no args passed: try default kibana start binary
  exec /usr/local/bin/kibana-docker
fi
