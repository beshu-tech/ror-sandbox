#!/bin/bash -e

echo "Preparing ES+KBN with X-Pack environment ..."

read_es_version () {
  while true; do
    read -p "Enter ES version: " esVersion
    if [ -z "$esVersion" ]; then
      echo "Empty ES version. Please try again ..."
      continue
    fi

    echo "ES_VERSION=$esVersion" >> .env
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

    echo "KBN_VERSION=$kbnVersion" >> .env
    break
  done
}

> .env
echo "-----------------"
read_es_version
echo "-----------------"
read_kbn_version
echo "-----------------"
