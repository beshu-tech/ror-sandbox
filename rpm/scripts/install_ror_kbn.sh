#!/bin/sh
set -eu

KBN_HOME="${KBN_HOME:-/usr/share/kibana}"
RPM_PAYLOAD_DIR="${RPM_PAYLOAD_DIR:-/opt/elasticsearch}"
ROR_KBN_ZIP="${ROR_KBN_ZIP:-${RPM_PAYLOAD_DIR}/readonlyrest_kbn_universal.zip}"
KBN_PLUGIN_BIN="${KBN_HOME}/bin/kibana-plugin"
ROR_KBN_PLUGIN_DIR="${KBN_HOME}/plugins/readonlyrestkbn"
ROR_KBN_TOOLS_JS="${ROR_KBN_PLUGIN_DIR}/ror-tools.js"

if [ ! -x "${KBN_PLUGIN_BIN}" ]; then
  echo "ERROR: kibana-plugin not found or not executable: ${KBN_PLUGIN_BIN}" >&2
  echo "Check KBN_HOME. Current KBN_HOME=${KBN_HOME}" >&2
  exit 1
fi

if [ ! -f "${ROR_KBN_ZIP}" ]; then
  echo "ERROR: ReadonlyREST Kibana plugin ZIP not found: ${ROR_KBN_ZIP}" >&2
  echo "Expected packaged RPM payload file: ${RPM_PAYLOAD_DIR}/readonlyrest_kbn_universal.zip" >&2
  exit 1
fi

if [ -d "${ROR_KBN_PLUGIN_DIR}" ]; then
  echo "ERROR: ReadonlyREST Kibana plugin is already installed: ${ROR_KBN_PLUGIN_DIR}" >&2
  echo "Uninstall it first using the uninstall script, then rerun this installer." >&2
  exit 1
fi

echo "Installing ReadonlyREST Kibana plugin from ${ROR_KBN_ZIP}..."
"${KBN_PLUGIN_BIN}" install "file://${ROR_KBN_ZIP}"

if [ ! -f "${ROR_KBN_TOOLS_JS}" ]; then
  echo "ERROR: ror-tools.js not found after plugin installation: ${ROR_KBN_TOOLS_JS}" >&2
  exit 1
fi

KBN_NODE_BIN=""

if [ -x "${KBN_HOME}/node/bin/node" ]; then
  KBN_NODE_BIN="${KBN_HOME}/node/bin/node"
elif [ -x "${KBN_HOME}/node/glibc-217/bin/node" ]; then
  KBN_NODE_BIN="${KBN_HOME}/node/glibc-217/bin/node"
elif [ -x "${KBN_HOME}/node/default/bin/node" ]; then
  KBN_NODE_BIN="${KBN_HOME}/node/default/bin/node"
else
  echo "ERROR: Kibana bundled Node.js binary was not found." >&2
  echo "Checked:" >&2
  echo "  ${KBN_HOME}/node/bin/node" >&2
  echo "  ${KBN_HOME}/node/glibc-217/bin/node" >&2
  echo "  ${KBN_HOME}/node/default/bin/node" >&2
  exit 1
fi

echo "Using Kibana Node.js: ${KBN_NODE_BIN}"

echo "Patching Kibana..."
"${KBN_NODE_BIN}" "${ROR_KBN_TOOLS_JS}" patch \
  --I_UNDERSTAND_AND_ACCEPT_KBN_PATCHING=yes

echo "Verifying Kibana patch..."
"${KBN_NODE_BIN}" "${ROR_KBN_TOOLS_JS}" verify

echo "ReadonlyREST Kibana plugin installed and patched successfully."
