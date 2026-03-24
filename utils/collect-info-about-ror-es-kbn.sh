#!/bin/bash -e

echo "Preparing Elasticsearch & Kibana with ROR environment ..."

if [[ -s ".env-showcase" ]]; then
  echo "Found .env-showcase - running in non-interactive mode ..."
  cp .env-showcase .env

  source .env-showcase

  if [[ "$ES_DOCKERFILE" == *"from-file"* ]]; then
    es_ror_info="FILE: $ES_ROR_FILE"
  else
    es_ror_info="API: ROR ES $ROR_ES_VERSION"
  fi

  if [[ "$KBN_DOCKERFILE" == *"from-file"* ]]; then
    kbn_ror_info="FILE: $KBN_ROR_FILE"
  else
    kbn_ror_info="API: ROR KBN $ROR_KBN_VERSION"
  fi

  echo "  Elasticsearch $ES_VERSION ($es_ror_info)"
  echo "  Kibana        $KBN_VERSION ($kbn_ror_info)"

  exit 0
fi

if ! command -v jq > /dev/null; then
  $(dirname "$0")/collect-info-about-ror-es-kbn-without-hints.sh
else
  $(dirname "$0")/collect-info-about-ror-es-kbn-with-hints.sh || {
    if [[ $? -eq 28 || $? -eq 128 ]]; then
      $(dirname "$0")/collect-info-about-ror-es-kbn-without-hints.sh
    else
      exit $?
    fi
  }
fi
