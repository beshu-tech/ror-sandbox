#!/bin/bash -e

echo "Preparing ES+KBN with ROR environment ..."

determine_ror_es_dockerfile () {
  read_es_version

  while true; do
    read -p "Use ES ROR:
1. From API
2. From FILE

Your choice: " choice

    case "$choice" in
      1 )
        export ES_DOCKERFILE="Dockerfile-use-ror-binaries-from-api"

        read_ror_es_version
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

read_ror_es_version () {
  while true; do
    read -p "Enter ES ROR version: " rorVersion
    if [ -z "$rorVersion" ]; then
      echo "Empty ES ROR version. Please try again ..."
      continue
    fi

    export ROR_ES_VERSION=$rorVersion
    break
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
  read_kbn_version

  while true; do
    read -p "Use KBN ROR:
 1. From API
 2. From FILE

Your choice: " choice

    case "$choice" in
      1 )
        export KBN_DOCKERFILE="Dockerfile-use-ror-binaries-from-api"

        read_ror_kbn_version
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

read_ror_kbn_version () {
  while true; do
    read -p "Enter ROR Kibana version: " rorVersion
    if [ -z "$rorVersion" ]; then
      echo "Empty ROR Kibana version. Please try again ..."
      continue
    fi

    export ROR_KBN_VERSION=$rorVersion
    break
  done
}

read_kbn_ror_file_path () {
  while true; do
    read -p "Enter KBN ROR file path (it has to be placed in $(dirname "$0")): " path
    if [ -f "$path" ]; then
      export KBN_ROR_FILE=$path
      break
    else
      echo "Cannot find file $path. Please try again ..."
      continue
    fi
  done
}

echo "-----------------"
determine_ror_es_dockerfile
echo "-----------------"
determine_ror_kbn_dockerfile
echo "-----------------"
