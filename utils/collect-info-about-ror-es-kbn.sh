#!/bin/bash -e

if ! command -v jq > /dev/null; then
  source ../utils/collect-info-about-ror-es-kbn-without-hitns.sh
else
  source ../utils/collect-info-about-ror-es-kbn-with-hints.sh
fi