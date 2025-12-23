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
