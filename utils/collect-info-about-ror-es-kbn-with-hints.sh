#!/bin/bash -e

echo "Preparing ES+KBN with ROR environment ..."

determine_ror_es_dockerfile () {
  ROR_API_RESPONSE=$1
  DEFAULT_ES_VERSION=$(echo "$ROR_API_RESPONSE" | jq .es[0] -cr)
  ES_VERSIONS=$(echo "$ROR_API_RESPONSE" | jq .es -cr)

  read_es_version "$DEFAULT_ES_VERSION" "$ES_VERSIONS"

  while true; do
    read -p "Use ES ROR:
1. From API
2. From FILE

Your choice: " choice

    case "$choice" in
      1 )
        export ES_DOCKERFILE="Dockerfile-use-ror-binaries-from-api"

        DEFAULT_ES_ROR_VERSION=$(echo "$ROR_API_RESPONSE" | jq .pluginVersion -cr) # todo: fixme
        ES_ROR_VERSIONS=$(echo "$ROR_API_RESPONSE" | jq .pluginVersion -cr)

        read_ror_es_version "$DEFAULT_ES_ROR_VERSION" "$ES_ROR_VERSIONS"
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
    read -p "Enter ES version (default: $DEFAULT_ES_VERSION): " esVersion
    if [ -z "$esVersion" ]; then
      export ES_VERSION=$DEFAULT_ES_VERSION
      break
    fi

    if [[ $AVAILABLE_ES_VERSIONS == *"$esVersion"* ]];
    then
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

  while true; do
    read -p "Enter ES ROR version (default: $DEFAULT_ES_ROR_VERSION): " rorVersion
    if [ -z "$rorVersion" ]; then
      export ROR_ES_VERSION=$DEFAULT_ES_ROR_VERSION
      break
    fi

    if [[ $AVAILABLE_ES_ROR_VERSIONS == *"$rorVersion"* ]];
    then
      export ROR_ES_VERSION=$rorVersion
      break
    else
      echo "ES ROR $rorVersion is not available. Please try again ..."
      continue
    fi
  done
}

read_es_ror_file_path () {
  while true; do
    read -p "Enter ES ROR file path (it has to be placed in $(dirname "$0")): " path
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
  DEFAULT_KBN_VERSION=$PICKED_ES_VERSION
  KBN_VERSIONS=$(echo "$ROR_API_RESPONSE" | jq .kbn_universal -cr)

  read_kbn_version "$DEFAULT_KBN_VERSION" "$KBN_VERSIONS"

  while true; do
    read -p "Use KBN ROR:
 1. From API
 2. From FILE

Your choice: " choice

    case "$choice" in
      1 )
        export KBN_DOCKERFILE="Dockerfile-use-ror-binaries-from-api"

        DEFAULT_KBN_ROR_VERSION=$(echo "$ROR_API_RESPONSE" | jq .pluginVersion -cr) # todo: fixme
        KBN_ROR_VERSIONS=$(echo "$ROR_API_RESPONSE" | jq .pluginVersion -cr)

        read_ror_kbn_version "$DEFAULT_KBN_ROR_VERSION" "$KBN_ROR_VERSIONS"
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

    if [[ $AVAILABLE_KBN_VERSIONS == *"$kbnVersion"* ]];
    then
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

  while true; do
    read -p "Enter ROR Kibana version (default: $DEFAULT_KBN_ROR_VERSION): " rorVersion
    if [ -z "$rorVersion" ]; then
      export ROR_KBN_VERSION=$DEFAULT_KBN_ROR_VERSION
      break
    fi

    if [[ $AVAILABLE_KBN_ROR_VERSIONS == *"$rorVersion"* ]];
    then
      export ROR_KBN_VERSION=$rorVersion
      break
    else
      echo "ROR Kibana $rorVersion is not available. Please try again ..."
      continue
    fi
  done
}

read_kbn_ror_file_path () {
  while true; do
    read -p "Enter KBN ROR file path (it has to be placed in $(dirname "$0")): " path
    if [ -f "$path" ]; then
      export KBN_ROR_FILE=$path
    else
      echo "Cannot find file $path. Please try again ..."
      continue
    fi
  done
}


ROR_API_RESPONSE='{"es":["8.6.0"], "kbn_universal":["8.6.0"], "pluginVersion":"1.46.0"}'
STATUS_CODE=$(curl -s -o /tmp/ror-api-response.txt -w "%{http_code}" https://api.beshu.tech/list_es_versions)

if [[ "$STATUS_CODE" -eq 200 ]] ; then
  ROR_API_RESPONSE=$(cat /tmp/ror-api-response.txt)
  rm /tmp/ror-api-response.txt
fi

echo "-----------------"
determine_ror_es_dockerfile "$ROR_API_RESPONSE"
echo "-----------------"
determine_ror_kbn_dockerfile "$ROR_API_RESPONSE" "$ES_VERSION"
echo "-----------------"
