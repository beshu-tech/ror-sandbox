#!/bin/sh
set -eu

SYSTEMD_ES_SERVICE="${SYSTEMD_ES_SERVICE:-elasticsearch-es-01}"
SYSTEMD_KBN_SERVICE="${SYSTEMD_KBN_SERVICE:-kibana}"
SCRIPT_DIR="${SCRIPT_DIR:-/opt/elasticsearch/scripts}"

echo "Installing upgraded ReadonlyREST for Elasticsearch..."
"${SCRIPT_DIR}/install_ror_es.sh"

echo "Installing upgraded ReadonlyREST for Kibana..."
"${SCRIPT_DIR}/install_ror_kbn.sh"

echo "Starting Elasticsearch..."
systemctl start "${SYSTEMD_ES_SERVICE}"

echo "Starting Kibana..."
systemctl start "${SYSTEMD_KBN_SERVICE}"

echo "ReadonlyREST RPM post-upgrade completed successfully."
