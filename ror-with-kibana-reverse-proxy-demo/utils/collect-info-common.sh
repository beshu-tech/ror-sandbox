read_rewrite_base_path () {
  DEFAULT_REWRITE_BASE_PATH=true

  while true; do
    read -p "Rewrite base path? (true/false) [default: $DEFAULT_REWRITE_BASE_PATH]: " value

    if [[ -z "$value" ]]; then
      echo "REWRITE_BASE_PATH=$DEFAULT_REWRITE_BASE_PATH" >> .env
      break
    fi

    case "$value" in
      true|false)
        echo "REWRITE_BASE_PATH=$value" >> .env
        break
        ;;
      *)
        echo "Please enter true or false"
        ;;
    esac
  done
}
