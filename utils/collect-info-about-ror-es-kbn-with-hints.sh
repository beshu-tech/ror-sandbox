#!/bin/bash -e

echo "Preparing Elasticsearch & Kibana with ROR environment ..."

determine_ror_es_dockerfile () {
  ROR_API_RESPONSE=$1
  ES_VERSIONS_ARR=($(echo "$ROR_API_RESPONSE" | jq .[0] | jq 'to_entries | map(.value)' | jq .[].esVersions.es -cr | jq .[] -cr | uniq))
  DEFAULT_ES_VERSION=$(echo ${ES_VERSIONS_ARR[0]})
  ES_VERSIONS_STR=$(printf "%s," "${ES_VERSIONS_ARR[@]}")

  read_es_version "$DEFAULT_ES_VERSION" "$ES_VERSIONS_STR"

  while true; do
    read -p "Use ES ROR:
1. From API
2. From FILE

Your choice: " choice

    case "$choice" in
      1 )
        export ES_DOCKERFILE="Dockerfile-use-ror-binaries-from-api"

        ES_ROR_VERSIONS_ARR=($(echo "$ROR_API_RESPONSE" | jq .[0] | jq 'to_entries | map(.value)' | jq .[].pluginVersion -cr))
        DEFAULT_ES_ROR_VERSION=$(echo ${ES_ROR_VERSIONS_ARR[0]})
        ES_ROR_VERSIONS_STR=$(printf "%s," "${ES_ROR_VERSIONS_ARR[@]}")

        read_ror_es_version "$DEFAULT_ES_ROR_VERSION" "$ES_ROR_VERSIONS_STR" "$ROR_API_RESPONSE"
        break
        ;;
      2 )
        export ES_DOCKERFILE="Dockerfile-use-ror-binaries-from-file"
        read_es_ror_file_path
        break
        ;;
      * )
        echo "There is no such option to pick. Please try again ..."
        continue
        ;;
    esac
  done
}

read_es_version () {
  DEFAULT_ES_VERSION=$1
  AVAILABLE_ES_VERSIONS=$2

  while true; do
    read -p "Enter Elasticsearch version (default: $DEFAULT_ES_VERSION): " esVersion
    if [ -z "$esVersion" ]; then
      export ES_VERSION=$DEFAULT_ES_VERSION
      break
    fi

    if [[ $AVAILABLE_ES_VERSIONS == *"$esVersion"* ]]; then
      export ES_VERSION=$esVersion
      break
    else
      echo "ES $esVersion is not available. Please try again ..."
      continue
    fi
  done
}

read_ror_es_version () {
  DEFAULT_ES_ROR_VERSION=$1
  AVAILABLE_ES_ROR_VERSIONS=$2
  ROR_API_RESPONSE=$3

  while true; do
    read -p "Enter ROR Elasticsearch version (default: $DEFAULT_ES_ROR_VERSION): " rorVersion
    if [ -z "$rorVersion" ]; then
      export ROR_ES_VERSION=$DEFAULT_ES_ROR_VERSION
      break
    fi

    if [[ $AVAILABLE_ES_ROR_VERSIONS == *"$rorVersion"* ]]; then
      ES_VERSIONS_ARR=($(echo "$ROR_API_RESPONSE" | jq .[0] | jq '."'$rorVersion'".esVersions.es[]' -cr))
      for i in "${ES_VERSIONS_ARR[@]}"
      do
        if [[ $i == "$ES_VERSION" ]]; then
          export ROR_ES_VERSION=$rorVersion
          break 2
        fi
      done

      echo "ROR Elasticsearch $rorVersion is not available for Elasticsearch $ES_VERSION. Please try again ..."
      continue
    else
      echo "ROR Elasticsearch $rorVersion is not available. Please try again ..."
      continue
    fi
  done
}

read_es_ror_file_path () {
  while true; do
    read -p "Enter ROR Elasticsearch file path (it has to be placed in $(dirname "$0")): " path
    if [ -f "$path" ]; then
      export ES_ROR_FILE=$path
      break
    else
      echo "Cannot find file $path. Please try again ..."
      continue
    fi
  done
}

determine_ror_kbn_dockerfile () {
  ROR_API_RESPONSE=$1
  PICKED_ES_VERSION=$2

  KBN_VERSIONS_ARR=($(echo "$ROR_API_RESPONSE" | jq .[0] | jq 'to_entries | map(.value)' | jq .[].esVersions.kbn_universal -cr | jq .[] -cr | uniq))
  DEFAULT_KBN_VERSION=$PICKED_ES_VERSION
  KBN_VERSIONS_STR=$(printf "%s," "${KBN_VERSIONS_ARR[@]}")

  read_kbn_version "$DEFAULT_KBN_VERSION" "$KBN_VERSIONS_STR"

  while true; do
    read -p "Use KBN ROR:
 1. From API
 2. From FILE

Your choice: " choice

    case "$choice" in
      1 )
        export KBN_DOCKERFILE="Dockerfile-use-ror-binaries-from-api"

        KBN_ROR_VERSIONS_ARR=($(echo "$ROR_API_RESPONSE" | jq .[0] | jq 'to_entries | map(.value)' | jq .[].pluginVersion -cr))
        DEFAULT_KBN_ROR_VERSION=$(echo ${KBN_ROR_VERSIONS_ARR[0]})
        KBN_ROR_VERSIONS_STR=$(printf "%s," "${KBN_ROR_VERSIONS_ARR[@]}")

        read_ror_kbn_version "$DEFAULT_KBN_ROR_VERSION" "$KBN_ROR_VERSIONS_STR" "$ROR_API_RESPONSE"
        break
        ;;
      2 )
        export KBN_DOCKERFILE="Dockerfile-use-ror-binaries-from-file"
        read_kbn_ror_file_path
        break
        ;;
      * )
        echo "There is no such option to pick. Please try again ..."
        continue
        ;;
    esac
  done
}

read_kbn_version () {
  DEFAULT_KBN_VERSION=$1
  AVAILABLE_KBN_VERSIONS=$2

  while true; do
    read -p "Enter Kibana version (default: $DEFAULT_KBN_VERSION): " kbnVersion
    if [ -z "$kbnVersion" ]; then
      export KBN_VERSION=$DEFAULT_KBN_VERSION
      break
    fi

    if [[ $AVAILABLE_KBN_VERSIONS == *"$kbnVersion"* ]]; then
      export KBN_VERSION=$kbnVersion
      break
    else
      echo "Kibana $kbnVersion is not available. Please try again ..."
      continue
    fi
  done
}

read_ror_kbn_version () {
  DEFAULT_KBN_ROR_VERSION=$1
  AVAILABLE_KBN_ROR_VERSIONS=$2
  ROR_API_RESPONSE=$3

  while true; do
    read -p "Enter ROR Kibana version (default: $DEFAULT_KBN_ROR_VERSION): " rorVersion
    if [ -z "$rorVersion" ]; then
      export ROR_KBN_VERSION=$DEFAULT_KBN_ROR_VERSION
      break
    fi

    if [[ $AVAILABLE_KBN_ROR_VERSIONS == *"$rorVersion"* ]]; then
      KBN_VERSIONS_ARR=($(echo "$ROR_API_RESPONSE" | jq .[0] | jq '."'$rorVersion'".esVersions.kbn_universal[]' -cr))
      for i in "${KBN_VERSIONS_ARR[@]}"
      do
        if [[ $i == "$KBN_VERSION" ]]; then
          export ROR_KBN_VERSION=$rorVersion
          break 2
        fi
      done

      echo "ROR Kibana $rorVersion is not available for Kibana $KBN_VERSION. Please try again ..."
      continue
    else
      echo "ROR Kibana $rorVersion is not available. Please try again ..."
      continue
    fi
  done
}

read_kbn_ror_file_path () {
  while true; do
    read -p "Enter ROR Kibana file path (it has to be placed in $(dirname "$0")): " path
    if [ -f "$path" ]; then
      export KBN_ROR_FILE=$path
      break
    else
      echo "Cannot find file $path. Please try again ..."
      continue
    fi
  done
}


ROR_API_RESPONSE=''
STATUS_CODE=$(curl -s -o /tmp/ror-api-response.txt -w "%{http_code}" https://api.beshu.tech/list_es_versions/20)

if [[ "$STATUS_CODE" -eq 200 ]]; then
  ROR_API_RESPONSE=$(cat /tmp/ror-api-response.txt)
  rm /tmp/ror-api-response.txt
fi

echo "-----------------"
determine_ror_es_dockerfile "$ROR_API_RESPONSE"
echo "-----------------"
determine_ror_kbn_dockerfile "$ROR_API_RESPONSE" "$ES_VERSION"
echo "-----------------"
