#!/bin/bash -e

echo "Preparing ES+KBN with X-Pack environment ..."

read_es_version () {
  while true; do
    read -p "Enter ES version: " esVersion
    if [ -z "$esVersion" ]; then
      echo "Empty ES version. Please try again ..."
      continue
    fi

    export ES_VERSION=$esVersion
    break
  done
}

read_kbn_version () {
  while true; do
    read -p "Enter Kibana version: " kbnVersion
    if [ -z "$kbnVersion" ]; then
      echo "Empty Kibana version. Please try again ..."
      continue
    fi

    export KBN_VERSION=$kbnVersion
    break
  done
}

echo "-----------------"
read_es_version
echo "-----------------"
read_kbn_version
echo "-----------------"
