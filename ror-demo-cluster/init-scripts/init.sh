#!/bin/bash -ex

cd "$(dirname "$0")"

source utils/lib.sh

function generate_log_documents() {
  if [ "$#" -ne 1 ]; then
    echo "ERROR: One required: 1) number of documents to generate"
    return 1
  fi

  N=$1 

  for ((i = 1; i <= N; i++)); do
    user_id=$((RANDOM % 10000 + 1))
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ") 
    log_message="User $user_id login successful"
    level="$(pick_randomly "INFO" "WARN" "ERROR" "DEBUG")"

    echo "{ \"message\": \"$log_message\", \"level\": \"$level\", \"timestamp\": \"$timestamp\", \"user_id\": \"$user_id\" }"
  done
}

function index_documents() {
   if [ "$#" -ne 1 ]; then
    echo "ERROR: One required: 1) index name"
    return 1
  fi

  INDEX_NAME=$1 

  while IFS= read -r document; do
    putDocument "$INDEX_NAME" "$document"
  done
}

generate_log_documents 100 | index_documents "frontend_logs"
generate_log_documents 50 | index_documents "business_logs"
generate_log_documents 60 | index_documents "system_logs"
generate_log_documents 100 | index_documents "filebeat-2025.09"