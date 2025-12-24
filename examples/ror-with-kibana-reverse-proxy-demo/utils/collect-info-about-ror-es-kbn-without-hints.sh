#!/bin/bash -e

source "../../utils/collect-info-about-ror-es-kbn-without-hints-common.sh"
source "$(dirname "$0")/collect-info-common.sh"

> .env
echo "-----------------"
determine_ror_es_dockerfile
source .env

require_min_version $ES_VERSION 7.9.0

echo "-----------------"
determine_ror_kbn_dockerfile

source .env

require_min_version $KBN_VERSION 7.9.0

echo "-----------------"
read_REWRITE_BASE_PATH_BY_KIBANA
echo "-----------------"