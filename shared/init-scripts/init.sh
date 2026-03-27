#!/bin/bash -ex

cd "$(dirname "$0")"

source utils/lib.sh

createDataStream "logs-frontend-dev" && generate_log_documents 100 | putDocument "logs-frontend-dev"
createDataStream "logs-business-dev" && generate_log_documents 100 | putDocument "logs-business-dev"
createDataStream "logs-system-dev" && generate_log_documents 100 | putDocument "logs-system-dev"

createIndex "data-business-index" && generate_log_documents 100 | putDocument "data-business-index"