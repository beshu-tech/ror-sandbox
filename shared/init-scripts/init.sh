#!/bin/bash -ex

set -o pipefail

cd "$(dirname "$0")"

source utils/lib.sh

#createDataStream "logs-frontend-dev" && generate_log_documents 100 | putDocument "logs-frontend-dev"
#createDataStream "logs-business-dev" && generate_log_documents 100 | putDocument "logs-business-dev"
#createDataStream "logs-system-dev" && generate_log_documents 100 | putDocument "logs-system-dev"

#createKibanaDataView "logs-frontend-*" "Frontend logs" "@timestamp" "admin" "admin" "EndUsers"
#createKibanaDataView "logs-business-*" "Business logs" "@timestamp" "admin" "admin" "BusinessUsers"
#createKibanaDataView "logs-system-*" "System logs" "@timestamp" "admin" "admin" "Administrators"

#createIndex "data-business-index" && generate_log_documents 100 | putDocument "data-business-index"

createIndex "asdasd" && generate_log_documents 1 | putDocument "asdasd"
createIndex "xasdasd" && generate_log_documents 1 | putDocument "xasdasd"
createIndex "asdasdx" && generate_log_documents 1 | putDocument "asdasdx"
createIndex "xasdasdx" && generate_log_documents 1 | putDocument "xasdasdx"
createIndex "notmatching" && generate_log_documents 1 | putDocument "notmatching"
