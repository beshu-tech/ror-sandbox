#!/usr/bin/env bash
set -e

cd "$(dirname "$0")"

if ! command -v kind &> /dev/null; then
  echo "Cannot find 'kind' tool. Please follow the installation steps: https://github.com/kubernetes-sigs/kind#installation-and-usage"
  exit 1
fi

if ! command -v docker &> /dev/null; then
  echo "Cannot find 'docker'. Please follow the installation steps: https://docs.docker.com/engine/install/"
  exit 2
fi

show_help() {
  echo "Usage: ./start.sh --es <elasticsearch_version> --kbn <kibana_version> --eck <eck_version>"
  exit 1
}

export ES_VERSION=""
export KBN_VERSION=""
export ECK_VERSION="2.14.0"

while [[ $# -gt 0 ]]; do
  case $1 in
  --es)
    if [[ -n $2 && $2 != --* ]]; then
      ES_VERSION="$2"
      shift 2
    else
      echo "Error: --es requires a version argument"
      show_help
    fi
    ;;
  --kbn)
    if [[ -n $2 && $2 != --* ]]; then
      KBN_VERSION="$2"
      shift 2
    else
      echo "Error: --kbn requires a version argument"
      show_help
    fi
    ;;
  --eck)
      if [[ -n $2 && $2 != --* ]]; then
        ECK_VERSION="$2"
        shift 2
      else
        echo "Error: --eck requires a version argument"
        show_help
      fi
      ;;
  *)
    echo "Unknown option: $1"
    show_help
    ;;
  esac
done

if [[ -z $ES_VERSION || -z $KBN_VERSION ]]; then
  echo "Error: Both --es and --kbn arguments are required"
  show_help
fi

echo "CONFIGURING K8S CLUSTER ..."
kind create cluster --name xpack-eck --config kind-cluster/kind-cluster-config.yml
docker exec xpack-eck-control-plane /bin/bash -c "sysctl -w vm.max_map_count=262144"
docker exec xpack-eck-worker        /bin/bash -c "sysctl -w vm.max_map_count=262144"
docker exec xpack-eck-worker2       /bin/bash -c "sysctl -w vm.max_map_count=262144"

echo "CONFIGURING ECK $ECK_VERSION ..."
docker cp kind-cluster/bootstrap-eck.sh xpack-eck-control-plane:/
docker exec xpack-eck-control-plane chmod +x bootstrap-eck.sh
docker exec xpack-eck-control-plane bash -c "export ECK_VERSION=$ECK_VERSION && ./bootstrap-eck.sh"

echo "CONFIGURING ES $ES_VERSION AND KBN $KBN_VERSION ..."

SUBSTITUTED_DIR="kind-cluster/subst-xpack"
cleanup() {
  rm -rf "$SUBSTITUTED_DIR"
}

trap cleanup EXIT
mkdir -p "$SUBSTITUTED_DIR"

subsitute_env_in_yaml_templates() {
  MAJOR_VERSION=$(echo "$ES_VERSION" | cut -d '.' -f1)
  MINOR_VERSION=$(echo "$ES_VERSION" | cut -d '.' -f2)

  if [[ "$MAJOR_VERSION" -eq 7 && "$MINOR_VERSION" -le 16 ]]; then
    export ELATICSEARCH_USER="elasticsearch.username: kibana"
    export ELATICSEARCH_PASSWORD="elasticsearch.password: kibana"
    export QUICK_KIBANA_USER_SECRET_KEY="default-quickstart-kibana-user"
  else
    export QUICK_KIBANA_USER_SECRET_KEY="token"
  fi
  
  for file in kind-cluster/xpack/*.yml; do
    filename=$(basename "$file")
    if [[ "$filename" == "es.yml" || "$filename" == "kbn.yml" ]]; then
      envsubst < "$file" > "$SUBSTITUTED_DIR/$filename"
    else
      cp "$file" "$SUBSTITUTED_DIR"
    fi
  done

  docker cp "$SUBSTITUTED_DIR" xpack-eck-control-plane:/xpack/
}

subsitute_env_in_yaml_templates

docker exec xpack-eck-control-plane bash -c 'cd xpack && ls | xargs -n 1 kubectl apply -f'

echo ""
echo "------------------------------------------"
echo "ECK is being bootstrapped..."
echo ""

check_pods_running() {
  pod_status=$(docker exec xpack-eck-control-plane kubectl get pods | grep quickstart)

  all_ready=true
  while read -r line; do
    ready=$(echo "$line" | awk '{print $2}')
    status=$(echo "$line" | awk '{print $3}')
    
    if [[ "$status" != "Running" || "$ready" != "1/1" ]]; then
      all_ready=false
    fi
  done <<< "$pod_status"
  echo -e "$pod_status"

  $all_ready && return 0 || return 1
}

TIMEOUT_IN_SECONDS=300
INTERVAL_IN_SECONDS=5

echo "Waiting for all pods to be in Running and Ready state (1/1)..."
elapsed_time=0
while ! check_pods_running; do
  sleep $INTERVAL_IN_SECONDS

  elapsed_time=$((elapsed_time + INTERVAL_IN_SECONDS))
  if [[ "$elapsed_time" -ge "$TIMEOUT_IN_SECONDS" ]]; then
    echo "Timeout reached after $TIMEOUT_IN_SECONDS seconds."
    exit 1
  fi
done
echo "All pods are in Running and Ready (1/1) state."

SECRET=$(kubectl get secret quickstart-es-elastic-user -o=jsonpath='{.data.elastic}' | base64 --decode; echo)
if [ -z "$SECRET" ]; then
  echo "Error: Cannot get the ES user secret!"
  exit 1
fi
echo "Open your browser and try to access https://localhost:5601/ (credentials elastic:$SECRET)"
