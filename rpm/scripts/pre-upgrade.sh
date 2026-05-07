#!/bin/sh
set -eu

SYSTEMD_ES_SERVICE="${SYSTEMD_ES_SERVICE:-elasticsearch-es-01}"
SYSTEMD_KBN_SERVICE="${SYSTEMD_KBN_SERVICE:-kibana}"
SCRIPT_DIR="${SCRIPT_DIR:-/opt/elasticsearch/scripts}"

echo "Preparing ReadonlyREST RPM upgrade."

echo "Stopping Kibana..."
systemctl stop "${SYSTEMD_KBN_SERVICE}"

echo "Stopping Elasticsearch..."
systemctl stop "${SYSTEMD_ES_SERVICE}"

echo "Uninstalling existing ReadonlyREST for Kibana before upgrade..."
"${SCRIPT_DIR}/uninstall_ror_kbn.sh"

echo "Uninstalling existing ReadonlyREST for Elasticsearch before upgrade..."
"${SCRIPT_DIR}/uninstall_ror_es.sh"

echo "ReadonlyREST RPM pre-upgrade completed successfully."
