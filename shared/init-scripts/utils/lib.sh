#!/bin/bash -ex

function pick_randomly() {
  local OPTIONS=("$@") 
  local COUNT=${#OPTIONS[@]} 
  local RANDOM_INDEX=$((RANDOM % COUNT)) 
  echo "${OPTIONS[$RANDOM_INDEX]}"
}

function createIndex() {
  if [ "$#" -ne 1 ]; then
    echo "ERROR: One parameter required: 1) index name"
    return 1
  fi

  if ! [ -v ELASTICSEARCH_ADDRESS ] || [ -z "$ELASTICSEARCH_ADDRESS" ]; then
    echo "ERROR: required variable ELASTICSEARCH_ADDRESS not set or empty"
    exit 2
  fi

  if ! [ -v ELASTICSEARCH_USER ] || [ -z "$ELASTICSEARCH_USER" ]; then
    echo "ERROR: required variable ELASTICSEARCH_USER not set or empty"
    exit 3
  fi

  if ! [ -v ELASTICSEARCH_PASSWORD ] || [ -z "$ELASTICSEARCH_PASSWORD" ]; then
    echo "ERROR: required variable ELASTICSEARCH_PASSWORD not set or empty"
    exit 4
  fi

  INDEX_NAME=$1

  response=$(curl -k -s -L -w "\n%{http_code}" -u "$ELASTICSEARCH_USER":"$ELASTICSEARCH_PASSWORD" \
    -X PUT "$ELASTICSEARCH_ADDRESS/$INDEX_NAME" \
    -H "Content-Type: application/json"
  )

  http_status=$(echo "$response" | tail -n 1)
  response_body=$(echo "$response" | sed \$d)

  if [[ "$http_status" != 2* ]]; then
    echo "ERROR: Cannot create index [$INDEX_NAME]. HTTP status: $http_status, response body: $response_body"
    return 5
  fi

  return 0
}

function createDataStream() {
  if [ "$#" -ne 1 ]; then
    echo "ERROR: One parameter required: 1) data stream name"
    return 1
  fi

  if ! [ -v ELASTICSEARCH_ADDRESS ] || [ -z "$ELASTICSEARCH_ADDRESS" ]; then
    echo "ERROR: required variable ELASTICSEARCH_ADDRESS not set or empty"
    exit 2
  fi

  if ! [ -v ELASTICSEARCH_USER ] || [ -z "$ELASTICSEARCH_USER" ]; then
    echo "ERROR: required variable ELASTICSEARCH_USER not set or empty"
    exit 3
  fi

  if ! [ -v ELASTICSEARCH_PASSWORD ] || [ -z "$ELASTICSEARCH_PASSWORD" ]; then
    echo "ERROR: required variable ELASTICSEARCH_PASSWORD not set or empty"
    exit 4
  fi

  STREAM_NAME=$1
  TEMPLATE_NAME="${STREAM_NAME}-template"

  response=$(curl -k -s -L -w "\n%{http_code}" -u "$ELASTICSEARCH_USER":"$ELASTICSEARCH_PASSWORD" \
    -X PUT "$ELASTICSEARCH_ADDRESS/_index_template/$TEMPLATE_NAME" \
    -H "Content-Type: application/json" -d "{
      \"index_patterns\": [\"$STREAM_NAME\"],
      \"data_stream\": {},
      \"priority\": 500
    }"
  )

  http_status=$(echo "$response" | tail -n 1)
  response_body=$(echo "$response" | sed \$d)

  if [[ "$http_status" != 2* ]]; then
    echo "ERROR: Cannot create index template for data stream [$STREAM_NAME]. HTTP status: $http_status, response body: $response_body"
    return 5
  fi

  response=$(curl -k -s -L -w "\n%{http_code}" -u "$ELASTICSEARCH_USER":"$ELASTICSEARCH_PASSWORD" \
    -X PUT "$ELASTICSEARCH_ADDRESS/_data_stream/$STREAM_NAME"
  )

  http_status=$(echo "$response" | tail -n 1)
  response_body=$(echo "$response" | sed \$d)

  if [[ "$http_status" != 2* ]]; then
    echo "ERROR: Cannot create data stream [$STREAM_NAME]. HTTP status: $http_status, response body: $response_body"
    return 6
  fi

  return 0
}

function createKibanaDataView() {
  if [ "$#" -lt 1 ] || [ "$#" -gt 6 ]; then
    echo "ERROR: Required: 1) index pattern (title); optionally 2) data view name, 3) time field name, 4) Kibana user, 5) Kibana password, 6) tenancy (ROR group)"
    return 1
  fi

  if ! [ -v KIBANA_ADDRESS ] || [ -z "$KIBANA_ADDRESS" ]; then
    echo "ERROR: required variable KIBANA_ADDRESS not set or empty"
    exit 2
  fi

  INDEX_PATTERN=$1
  DATA_VIEW_NAME=${2:-$INDEX_PATTERN}
  TIME_FIELD_NAME=$3
  KBN_USER=${4:-${KIBANA_USER:-}}
  KBN_PASS=${5:-${KIBANA_PASSWORD:-}}
  TENANCY=$6

  if [ -z "$KBN_USER" ]; then
    echo "ERROR: Kibana user not provided (param 4) and KIBANA_USER env not set"
    exit 3
  fi

  if [ -z "$KBN_PASS" ]; then
    echo "ERROR: Kibana password not provided (param 5) and KIBANA_PASSWORD env not set"
    exit 4
  fi

  data_view_fields="\"title\": \"$INDEX_PATTERN\", \"name\": \"$DATA_VIEW_NAME\""
  if [ -n "$TIME_FIELD_NAME" ]; then
    data_view_fields="$data_view_fields, \"timeFieldName\": \"$TIME_FIELD_NAME\""
  fi

  tenancy_header=()
  tenancy_info="no tenancy header"
  if [ -n "$TENANCY" ]; then
    tenancy_header=(-H "x-ror-tenancy-id: $TENANCY")
    tenancy_info="tenancy: [$TENANCY]"
  fi

  response=$(curl -k -s -L -w "\n%{http_code}" -u "$KBN_USER":"$KBN_PASS" \
    -X POST "$KIBANA_ADDRESS/api/data_views/data_view" \
    -H "Content-Type: application/json" \
    -H "kbn-xsrf: true" \
    "${tenancy_header[@]}" -d "{
      \"data_view\": { $data_view_fields }
    }"
  )

  http_status=$(echo "$response" | tail -n 1)
  response_body=$(echo "$response" | sed \$d)

  if [[ "$http_status" != 2* ]]; then
    echo "ERROR: Cannot create Kibana data view [$DATA_VIEW_NAME] for index pattern [$INDEX_PATTERN] ($tenancy_info). HTTP status: $http_status, response body: $response_body"
    return 5
  fi

  return 0
}

function putDocument() {
  if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
    echo "ERROR: Required: 1) index name, optionally 2) document JSON string (or via stdin)"
    return 1
  fi

  if ! [ -v ELASTICSEARCH_ADDRESS ] || [ -z "$ELASTICSEARCH_ADDRESS" ]; then
    echo "ERROR: required variable ELASTICSEARCH_ADDRESS not set or empty"
    exit 2
  fi

  if ! [ -v ELASTICSEARCH_USER ] || [ -z "$ELASTICSEARCH_USER" ]; then
    echo "ERROR: required variable ELASTICSEARCH_USER not set or empty"
    exit 3
  fi

  if ! [ -v ELASTICSEARCH_PASSWORD ] || [ -z "$ELASTICSEARCH_PASSWORD" ]; then
    echo "ERROR: required variable ELASTICSEARCH_PASSWORD not set or empty"
    exit 4
  fi

  INDEX_NAME=$1

  if [ "$#" -eq 2 ]; then
    putSingleDocument "$INDEX_NAME" "$2"
  else
    while IFS= read -r DOCUMENT_CONTENT; do
      putSingleDocument "$INDEX_NAME" "$DOCUMENT_CONTENT" || return $?
    done
  fi
}

function putSingleDocument() {
  INDEX_NAME=$1
  DOCUMENT_CONTENT=$2

  response=$(curl -k -s -L -w "\n%{http_code}" -u "$ELASTICSEARCH_USER":"$ELASTICSEARCH_PASSWORD" \
    -X POST "$ELASTICSEARCH_ADDRESS/$INDEX_NAME/_doc/" \
    -H "Content-Type: application/json" -d "$DOCUMENT_CONTENT"
  )

  http_status=$(echo "$response" | tail -n 1)
  response_body=$(echo "$response" | sed \$d)

  if [[ "$http_status" != 2* ]] ; then
    echo "ERROR: Cannot add document [$DOCUMENT_CONTENT] to index=[$INDEX_NAME].\nHTTP status: $http_status, response body: $response_body"
    return 5
  fi

  return 0
}

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

    echo "{ \"message\": \"$log_message\", \"level\": \"$level\", \"@timestamp\": \"$timestamp\", \"user_id\": \"$user_id\" }"
  done
}