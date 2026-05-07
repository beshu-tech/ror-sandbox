#!/bin/sh
set -eu

ES_HOME="${ES_HOME:-/usr/share/elasticsearch}"
ES_CONF="${ES_PATH_CONF:-/etc/elasticsearch/es-01}"
RPM_PAYLOAD_DIR="${RPM_PAYLOAD_DIR:-/opt/elasticsearch}"
ROR_ES_ZIP="${ROR_ES_ZIP:-${RPM_PAYLOAD_DIR}/readonlyrest.zip}"
ES_PLUGIN_BIN="${ES_HOME}/bin/elasticsearch-plugin"
ES_JAVA_BIN="${ES_HOME}/jdk/bin/java"
ROR_PLUGIN_DIR="${ES_HOME}/plugins/readonlyrest"
ROR_TOOLS_JAR="${ROR_PLUGIN_DIR}/ror-tools.jar"

if [ ! -x "${ES_PLUGIN_BIN}" ]; then
  echo "ERROR: elasticsearch-plugin not found or not executable: ${ES_PLUGIN_BIN}" >&2
  echo "Check ES_HOME. Current ES_HOME=${ES_HOME}" >&2
  exit 1
fi

if [ ! -x "${ES_JAVA_BIN}" ]; then
  echo "ERROR: Elasticsearch bundled Java not found or not executable: ${ES_JAVA_BIN}" >&2
  echo "Check ES_HOME. Current ES_HOME=${ES_HOME}" >&2
  exit 1
fi

if [ ! -d "${ES_CONF}" ]; then
  echo "ERROR: Elasticsearch config directory not found: ${ES_CONF}" >&2
  echo "Set ES_PATH_CONF to the correct config directory." >&2
  exit 1
fi

if [ ! -f "${ROR_ES_ZIP}" ]; then
  echo "ERROR: ReadonlyREST Elasticsearch plugin ZIP not found: ${ROR_ES_ZIP}" >&2
  echo "Expected packaged RPM payload file: ${RPM_PAYLOAD_DIR}/readonlyrest.zip" >&2
  exit 1
fi

if [ -d "${ROR_PLUGIN_DIR}" ]; then
  echo "ERROR: ReadonlyREST Elasticsearch plugin is already installed: ${ROR_PLUGIN_DIR}" >&2
  echo "Uninstall it first using the uninstall script, then rerun this installer." >&2
  exit 1
fi

export ES_PATH_CONF="${ES_CONF}"

echo "Installing ReadonlyREST Elasticsearch plugin from ${ROR_ES_ZIP}..."
"${ES_PLUGIN_BIN}" install --batch "file://${ROR_ES_ZIP}"

if [ ! -f "${ROR_TOOLS_JAR}" ]; then
  echo "ERROR: ror-tools.jar not found after plugin installation: ${ROR_TOOLS_JAR}" >&2
  exit 1
fi

echo "Patching Elasticsearch..."
"${ES_JAVA_BIN}" -jar "${ROR_TOOLS_JAR}" patch \
  --I_UNDERSTAND_AND_ACCEPT_ES_PATCHING=yes \
  --es-path="${ES_HOME}"

echo "Verifying Elasticsearch patch..."
"${ES_JAVA_BIN}" -jar "${ROR_TOOLS_JAR}" verify --es-path="${ES_HOME}"

echo "ReadonlyREST Elasticsearch plugin installed and patched successfully."
