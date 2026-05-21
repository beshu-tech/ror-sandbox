#!/bin/bash -ex

set -o pipefail

cd "$(dirname "$0")"

source utils/lib.sh

createDataStream "logs-frontend-dev" && generate_log_documents 100 | putDocument "logs-frontend-dev"
createDataStream "logs-business-dev" && generate_log_documents 100 | putDocument "logs-business-dev"
createDataStream "logs-system-dev" && generate_log_documents 100 | putDocument "logs-system-dev"

createIndex "data-business-index" && generate_log_documents 100 | putDocument "data-business-index"

createKibanaDataView "admin" "admin" "logs-frontend-*" "Frontend logs" "@timestamp" "g1"
createKibanaDataView "admin" "admin" "logs-business-*" "Business logs" "@timestamp" "g1"
createKibanaDataView "admin" "admin" "logs-system-*" "System logs" "@timestamp" "g2"
