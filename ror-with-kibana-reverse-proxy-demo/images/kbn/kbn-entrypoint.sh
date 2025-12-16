#!/bin/bash
set -euo pipefail

# Normalize various truthy/falsey values to "true" or "false"
_normalize_bool() {
  local v="${1:-}"
  v="${v,,}"               # lowercase
  case "$v" in
    1|true|yes|y) echo "true" ;;
    0|false|no|n) echo "false" ;;
    *) echo "" ;;
  esac
}

# Replace or prepend a simple top-level YAML key (dotted keys allowed)
_upsert_yaml_key() {
  local cfg_file="$1"
  local key="$2"
  local val="$3"
  [ -f "$cfg_file" ] || return 0
  # escape dots for grep/sed
  local key_esc
  key_esc="$(printf '%s' "$key" | sed 's/\./\\./g')"
  if grep -qE "^${key_esc}:" "$cfg_file"; then
    sed -i.bak "s/^${key_esc}:.*/${key}: ${val}/" "$cfg_file" || true
  else
    printf '%s: %s\n' "${key}" "${val}" | cat - "$cfg_file" > "$cfg_file".tmp && mv "$cfg_file".tmp "$cfg_file"
  fi
}

# Function to replace or prepend server.name in a YAML file (keeps original behavior)
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

# Primary runtime config (kibana.yml)
cfg="/usr/share/kibana/config/kibana.yml"
if [ ! -f "$cfg" ]; then
  touch "$cfg"
fi

# Inject SERVER_NAME if provided
if [ -n "${SERVER_NAME:-}" ]; then
  _replace_server_name_in_file "$cfg" "${SERVER_NAME}"

  # Also update template configs so source templates include server.name
  for tmpl in \
    /usr/share/kibana/config/enterprise-ror-kibana.yml \
    /usr/share/kibana/config/pro-ror-kibana.yml \
    /usr/share/kibana/config/free-ror-kibana.yml; do
    _replace_server_name_in_file "$tmpl" "${SERVER_NAME}"
  done
fi

# Inject REWRITE_BASE_PATH_BY_KIBANA if provided (runtime toggle)
if [ -n "${REWRITE_BASE_PATH_BY_KIBANA:-}" ]; then
  rbp="$(_normalize_bool "${REWRITE_BASE_PATH_BY_KIBANA}")"
  if [ -n "$rbp" ]; then
    # set top-level dotted key server.rewriteBasePath: true|false
    _upsert_yaml_key "$cfg" "server.rewriteBasePath" "$rbp"

    for tmpl in \
      /usr/share/kibana/config/enterprise-ror-kibana.yml \
      /usr/share/kibana/config/pro-ror-kibana.yml \
      /usr/share/kibana/config/free-ror-kibana.yml; do
      _upsert_yaml_key "$tmpl" "server.rewriteBasePath" "$rbp"
    done

    echo "INFO: Applied server.rewriteBasePath=${rbp} to $cfg and templates"
  else
    echo "WARN: REWRITE_BASE_PATH_BY_KIBANA set but value not recognized: ${REWRITE_BASE_PATH_BY_KIBANA}"
  fi
fi

# Exec original CMD
if [ $# -gt 0 ]; then
  exec "$@"
else
  # no args passed: try default kibana start binary
  exec /usr/local/bin/kibana-docker
fi
