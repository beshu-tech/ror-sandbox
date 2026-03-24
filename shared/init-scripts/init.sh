#!/bin/bash -ex

cd "$(dirname "$0")"

source utils/lib.sh

createDataStream "logs-frontend-dev" && generate_log_documents 100 | putDocument "logs-frontend-dev"
createDataStream "logs-business-dev" && generate_log_documents 100 | putDocument "logs-business-dev"
createDataStream "logs-system-dev" && generate_log_documents 100 | putDocument "logs-system-dev"

#createIndex "frontend_logs_index" && generate_log_documents 100 | putDocument "frontend_logs_index"
#createIndex "business_logs_index" && generate_log_documents 50 | putDocument "business_logs_index"
#createIndex "system_logs_index" && generate_log_documents 60 | putDocument "system_logs_index"