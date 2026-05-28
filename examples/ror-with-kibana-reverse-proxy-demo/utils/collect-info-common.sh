read_REWRITE_BASE_PATH_BY_KIBANA () {
  DEFAULT_REWRITE_BASE_PATH_BY_KIBANA=true

  while true; do
    read -p "Rewrite base path by Kibana? (true/false) [default: $DEFAULT_REWRITE_BASE_PATH_BY_KIBANA]: " value

    if [[ -z "$value" ]]; then
      echo "REWRITE_BASE_PATH_BY_KIBANA=$DEFAULT_REWRITE_BASE_PATH_BY_KIBANA" >> .env
      break
    fi

    case "$value" in
      true|false)
        echo "REWRITE_BASE_PATH_BY_KIBANA=$value" >> .env
        break
        ;;
      *)
        echo "Please enter true or false"
        ;;
    esac
  done
}

function greater_than_or_equal() {
  # Strip the -pre part (or any suffix starting with -) from both versions
  version_1=$(echo "$1" | sed 's/-pre.*//')
  version_2=$(echo "$2" | sed 's/-pre.*//')
  [ "$version_1" = "$(echo -e "$version_1\n$version_2" | sort -V | tail -n 1)" ];
}

require_min_version() {
  local provided_version="$1"
  local min_version="$2"

  if ! greater_than_or_equal $provided_version $min_version; then
    echo "ERROR: ror-with-kibana-reverse-proxy-demo does not support Elasticsearch/Kibana versions lower than $min_version"
    exit 3
  fi
}