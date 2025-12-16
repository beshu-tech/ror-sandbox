read_REWRITE_BASE_PATH_BY_KIBANA () {
  DEFAULT_REWRITE_BASE_PATH_BY_KIBANA_BY_Kibana=true

  while true; do
    read -p "Rewrite base path by Kibana? (true/false) [default: $DEFAULT_REWRITE_BASE_PATH_BY_KIBANA_BY_Kibana]: " value

    if [[ -z "$value" ]]; then
      echo "REWRITE_BASE_PATH_BY_KIBANA=$DEFAULT_REWRITE_BASE_PATH_BY_KIBANA_BY_Kibana" >> .env
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
