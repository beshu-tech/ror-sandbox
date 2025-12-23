#!/bin/bash -e

echo "Preparing Elasticsearch & Kibana with ROR environment ..."

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
