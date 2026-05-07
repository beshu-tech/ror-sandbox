#!/bin/sh
set -eu

KBN_HOME="${KBN_HOME:-/usr/share/kibana}"

KBN_PLUGIN_BIN="${KBN_HOME}/bin/kibana-plugin"
ROR_KBN_PLUGIN_DIR="${KBN_HOME}/plugins/readonlyrestkbn"
ROR_KBN_TOOLS_JS="${ROR_KBN_PLUGIN_DIR}/ror-tools.js"

find_kibana_node() {
  if [ -x "${KBN_HOME}/node/bin/node" ]; then
    echo "${KBN_HOME}/node/bin/node"
  elif [ -x "${KBN_HOME}/node/glibc-217/bin/node" ]; then
    echo "${KBN_HOME}/node/glibc-217/bin/node"
  elif [ -x "${KBN_HOME}/node/default/bin/node" ]; then
    echo "${KBN_HOME}/node/default/bin/node"
  else
    echo "ERROR: Kibana bundled Node.js binary was not found." >&2
    echo "Checked:" >&2
    echo "  ${KBN_HOME}/node/bin/node" >&2
    echo "  ${KBN_HOME}/node/glibc-217/bin/node" >&2
    echo "  ${KBN_HOME}/node/default/bin/node" >&2
    exit 1
  fi
}

if [ ! -d "${KBN_HOME}" ]; then
  echo "ERROR: Kibana home directory not found: ${KBN_HOME}" >&2
  echo "Check KBN_HOME." >&2
  exit 1
fi

if [ ! -x "${KBN_PLUGIN_BIN}" ]; then
  echo "ERROR: kibana-plugin not found or not executable: ${KBN_PLUGIN_BIN}" >&2
  echo "Check KBN_HOME. Current KBN_HOME=${KBN_HOME}" >&2
  exit 1
fi

if [ ! -d "${ROR_KBN_PLUGIN_DIR}" ]; then
  echo "ReadonlyREST Kibana plugin is not installed: ${ROR_KBN_PLUGIN_DIR}"
  exit 0
fi

if [ ! -f "${ROR_KBN_TOOLS_JS}" ]; then
  echo "ERROR: ror-tools.js not found: ${ROR_KBN_TOOLS_JS}" >&2
  echo "Cannot safely unpatch Kibana before removing the plugin." >&2
  exit 1
fi

KBN_NODE_BIN="$(find_kibana_node)"

echo "Using Kibana Node.js: ${KBN_NODE_BIN}"

echo "Unpatching Kibana..."
"${KBN_NODE_BIN}" "${ROR_KBN_TOOLS_JS}" unpatch

echo "Verifying Kibana is no longer patched..."
if "${KBN_NODE_BIN}" "${ROR_KBN_TOOLS_JS}" verify; then
  echo "ERROR: Kibana still appears to be patched after unpatch." >&2
  exit 1
else
  echo "Kibana is unpatched."
fi

echo "Removing ReadonlyREST Kibana plugin..."
"${KBN_PLUGIN_BIN}" remove readonlyrestkbn

echo "ReadonlyREST Kibana plugin unpatched and removed successfully."
