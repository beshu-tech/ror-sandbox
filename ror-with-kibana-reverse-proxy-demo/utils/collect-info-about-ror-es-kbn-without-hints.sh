#!/bin/bash -e

source "../utils/collect-info-about-ror-es-kbn-without-hints-common.sh"
source "$(dirname "$0")/collect-info-common.sh"

> .env
echo "-----------------"
determine_ror_es_dockerfile
echo "-----------------"
determine_ror_kbn_dockerfile
echo "-----------------"
read_rewrite_base_path
echo "-----------------"