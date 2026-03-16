#!/bin/bash -ex

cd "$(dirname "$0")"

source utils/lib.sh

#createDataStream "frontend_logs_ds" && generate_log_documents 100 | putDocument "frontend_logs_ds"
#createDataStream "business_logs_ds" && generate_log_documents 50 | putDocument "business_logs_ds"
#createDataStream "system_logs_ds" && generate_log_documents 60 | putDocument "system_logs_ds"

#createIndex "frontend_logs_index" && generate_log_documents 100 | putDocument "frontend_logs_index"
#createIndex "business_logs_index" && generate_log_documents 50 | putDocument "business_logs_index"
#createIndex "system_logs_index" && generate_log_documents 60 | putDocument "system_logs_index"
