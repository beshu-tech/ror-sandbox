#!/bin/bash -ex

function pick_randomly() {
  local OPTIONS=("$@") 
  local COUNT=${#OPTIONS[@]} 
  local RANDOM_INDEX=$((RANDOM % COUNT)) 
  echo "${OPTIONS[$RANDOM_INDEX]}"
}

function putDocument() {
  if [ "$#" -ne 2 ]; then
    echo "ERROR: Three parameters required: 1) index name, 2) document JSON string"
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
  DOCUMENT_CONTENT=$2

  set -x 

  respone=$(curl -k -s -L -w "\n%{http_code}" -u $ELASTICSEARCH_USER:$ELASTICSEARCH_PASSWORD \
    -X POST "$ELASTICSEARCH_ADDRESS/$INDEX_NAME/_doc/" \
    -H "Content-Type: application/json" -d "$DOCUMENT_CONTENT"
  )

  http_status=$(echo "$respone" | tail -n 1)
  response_body=$(echo "$respone" | sed \$d)

  if [[ "$http_status" != 2* ]] ; then
    echo "ERROR: Cannot add document [$DOCUMENT_CONTENT] to index=[$INDEX_NAME].\nHTTP status: $HTTP_STATUS, response body: $RESPONSE_BODY"
    return 5
  fi

  return 0
}
