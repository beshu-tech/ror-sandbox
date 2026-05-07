#!/bin/sh

set -eu

SYSTEMD_ES_SERVICE="${SYSTEMD_ES_SERVICE:-elasticsearch-es-01}"
SYSTEMD_KBN_SERVICE="${SYSTEMD_KBN_SERVICE:-kibana}"
SCRIPT_DIR="${SCRIPT_DIR:-/opt/elasticsearch/scripts}"

echo "Stopping Kibana..."
systemctl stop "${SYSTEMD_KBN_SERVICE}"

echo "Stopping Elasticsearch..."
systemctl stop "${SYSTEMD_ES_SERVICE}"

echo "Installing ReadonlyREST for Elasticsearch..."
"${SCRIPT_DIR}/install_ror_es.sh"

echo "Installing ReadonlyREST for Kibana..."
"${SCRIPT_DIR}/install_ror_kbn.sh"

echo "Starting Elasticsearch..."
systemctl start "${SYSTEMD_ES_SERVICE}"

echo "Starting Kibana..."
systemctl start "${SYSTEMD_KBN_SERVICE}"

echo "ReadonlyREST RPM post-install completed successfully."