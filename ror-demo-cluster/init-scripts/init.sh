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

function ensure_testkeyword_index() {
  local index="test-keyword"
  local code
  code=$(curl -s -o /dev/null -w "%{http_code}" -u "$ES_USER:$ES_PASS" -X HEAD "$ES_URL/$index")
  if [ "$code" = "200" ]; then
    echo "Index '$index' already exists, skipping creation."
    return 0
  fi

  echo "Creating index '$index' with mapping..."
  curl -u "$ELASTICSEARCH_USER:$ELASTICSEARCH_PASSWORD" -sS -X PUT "$ELASTICSEARCH_ADDRESS/$index" \
    -H 'Content-Type: application/json' -d '{
      "mappings": {
        "properties": {
          "testing": {
            "type": "text",
            "fields": {
              "keyword": {
                "type": "keyword",
                "ignore_above": 256
              }
            }
          }
        }
      }
    }' | tee /dev/stderr
  echo
}

function generate_testkeyword_documents() {
  cat <<EOF
{ "testing": "Foo Bar" }
{ "testing": "foo bar" }
{ "testing": "FOO bar baz" }
{ "testing": "Bar; Foo" }
{ "testing": "bar" }
EOF
}

generate_log_documents 100 | index_documents "frontend_logs"
generate_log_documents 50 | index_documents "business_logs"
generate_log_documents 60 | index_documents "system_logs"

ensure_testkeyword_index
generate_testkeyword_documents | index_documents "test-keyword"