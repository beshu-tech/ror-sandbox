#!/bin/sh
set -eu

ES_HOME="${ES_HOME:-/usr/share/elasticsearch}"
ES_CONF="${ES_PATH_CONF:-/etc/elasticsearch/es-01}"
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

if [ ! -d "${ROR_PLUGIN_DIR}" ]; then
  echo "ReadonlyREST Elasticsearch plugin is not installed: ${ROR_PLUGIN_DIR}"
  exit 0
fi

if [ ! -f "${ROR_TOOLS_JAR}" ]; then
  echo "ERROR: ror-tools.jar not found: ${ROR_TOOLS_JAR}" >&2
  echo "Cannot safely unpatch Elasticsearch before removing the plugin." >&2
  exit 1
fi

export ES_PATH_CONF="${ES_CONF}"

echo "Unpatching Elasticsearch..."
"${ES_JAVA_BIN}" -jar "${ROR_TOOLS_JAR}" unpatch \
  --es-path="${ES_HOME}"

echo "Verifying Elasticsearch is no longer patched..."
if "${ES_JAVA_BIN}" -jar "${ROR_TOOLS_JAR}" verify \
  --es-path="${ES_HOME}"; then
  echo "ERROR: Elasticsearch still appears to be patched after unpatch." >&2
  exit 1
else
  echo "Elasticsearch is unpatched."
fi

echo "Removing ReadonlyREST Elasticsearch plugin..."
"${ES_PLUGIN_BIN}" remove readonlyrest

echo "ReadonlyREST Elasticsearch plugin unpatched and removed successfully."
