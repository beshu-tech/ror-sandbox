#!/bin/sh
set -eu

SYSTEMD_ES_SERVICE="${SYSTEMD_ES_SERVICE:-elasticsearch-es-01}"
SYSTEMD_KBN_SERVICE="${SYSTEMD_KBN_SERVICE:-kibana}"
SCRIPT_DIR="${SCRIPT_DIR:-/opt/elasticsearch/scripts}"

echo "Final uninstall of ROR config RPM."

echo "Stopping Kibana..."
systemctl stop "${SYSTEMD_KBN_SERVICE}"

echo "Stopping Elasticsearch..."
systemctl stop "${SYSTEMD_ES_SERVICE}"

echo "Uninstalling ReadonlyREST for Kibana..."
"${SCRIPT_DIR}/uninstall_ror_kbn.sh"

echo "Uninstalling ReadonlyREST for Elasticsearch..."
"${SCRIPT_DIR}/uninstall_ror_es.sh"

echo "Starting Elasticsearch..."
systemctl start "${SYSTEMD_ES_SERVICE}"

echo "Starting Kibana..."
systemctl start "${SYSTEMD_KBN_SERVICE}"

echo "ReadonlyREST RPM pre-uninstall completed successfully."
