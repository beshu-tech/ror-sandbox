#!/bin/bash -x

# Helper function to execute curl and check for 2xx status code
check_curl() {
  local description="$1"
  shift
  
  echo "Executing: $description"
  
  # Execute curl and capture both output and HTTP status code
  local http_code
  local response
  response=$(curl -w "\n%{http_code}" "$@")
  http_code=$(echo "$response" | tail -n1)
  local body=$(echo "$response" | sed '$d')
  
  echo "Response body: $body"
  echo "HTTP Status: $http_code"
  
  # Check if status code is in 2xx range
  if [[ "$http_code" =~ ^2[0-9][0-9]$ ]]; then
    echo "✓ Success: $description (HTTP $http_code)"
    return 0
  else
    echo "✗ Failed: $description (HTTP $http_code)"
    return 1
  fi
}

while true; do
  if curl -f -i --cacert /certs/ca.crt -u kibana:kibana https://kibana:5601/api/features | grep -q 'content-type: application/json'; then

    set -x
    
    # Check Kibana status and publicBaseUrl
    echo "=== Checking Kibana Info ==="
    curl -s -u "kibana:kibana" --cacert /certs/ca.crt https://kibana:5601/api/status | jq '.version, .status'
    
    # First, check current Fleet settings
    echo "=== Current Fleet settings BEFORE our changes ==="
    curl -s -u "kibana:kibana" --cacert /certs/ca.crt https://kibana:5601/api/fleet/settings | jq .
    
    # Create agent policy
    if ! check_curl "Create Elastic Agent Policy" \
      -s -u "kibana:kibana" --cacert /certs/ca.crt \
      -XPOST -H "kbn-xsrf: kibana" -H "Content-type: application/json" \
      "https://kibana:5601/api/fleet/agent_policies" \
      -d '{"id":"elastic-policy","name":"Elastic-Policy","namespace":"default","monitoring_enabled":["logs","metrics"]}'; then
      echo "Failed to create agent policy, exiting..."
      exit 1
    fi

    # Create system package policy
    if ! check_curl "Create System Package Policy" \
      -s -u "kibana:kibana" --cacert /certs/ca.crt \
      -XPOST -H "kbn-xsrf: kibana" -H "Content-type: application/json" \
      "https://kibana:5601/api/fleet/package_policies" \
      -d '{"name":"Elastic-System-package","namespace":"default","policy_id":"elastic-policy", "package":{"name": "system", "version":"1.54.0"}}'; then
      echo "Failed to create system package policy, exiting..."
      exit 1
    fi

    # Get the latest available APM package version
    echo "=== Detecting APM package version ==="
    APM_VERSION=$(curl -s -u "kibana:kibana" --cacert /certs/ca.crt \
      "https://kibana:5601/api/fleet/epm/packages/apm" | jq -r '.item.version')
    
    if [ -z "$APM_VERSION" ] || [ "$APM_VERSION" = "null" ]; then
      echo "ERROR: Could not detect APM package version"
      exit 1
    fi
    
    echo "Detected APM package version: $APM_VERSION"
    echo "======================================"

    # Create APM package policy
    if ! check_curl "Create APM Package Policy" \
      -s -u "kibana:kibana" --cacert /certs/ca.crt \
      -XPOST -H "kbn-xsrf: kibana" -H "Content-type: application/json" \
      "https://kibana:5601/api/fleet/package_policies" \
      -d "{\"name\":\"apm2\",\"namespace\":\"default\",\"policy_id\":\"elastic-policy\", \"package\":{\"name\": \"apm\", \"version\":\"$APM_VERSION\"},\"inputs\":[{\"type\":\"apm\",\"enabled\":true,\"streams\":[],\"policy_template\":\"apmserver\",\"vars\":{\"host\":{\"value\":\"0.0.0.0:8200\",\"type\":\"text\"},\"url\":{\"value\":\"https://agent1:8200\",\"type\":\"text\"},\"tls_enabled\":{\"value\":true,\"type\":\"bool\"},\"tls_certificate\":{\"value\":\"/certs/agent1.crt\",\"type\":\"text\"},\"tls_key\":{\"value\":\"/certs/agent1.key\",\"type\":\"text\"}}}]}"; then
      echo "Failed to create APM package policy, exiting..."
      exit 1
    fi

    # Update fleet settings
    if ! check_curl "Update Fleet Settings" \
      -s -u "kibana:kibana" --cacert /certs/ca.crt \
      -XPUT -H "kbn-xsrf: kibana" -H "Content-type: application/json" \
      "https://kibana:5601/api/fleet/settings" \
      -d '{"fleet_server_hosts": ["https://fleet-server:8220"]}'; then
      echo "Failed to update fleet settings, exiting..."
      exit 1
    fi

    # Update fleet output
    if ! check_curl "Update Fleet Output" \
      -s -u "kibana:kibana" --cacert /certs/ca.crt \
      -XPUT -H "kbn-xsrf: kibana" -H "Content-type: application/json" \
      "https://kibana:5601/api/fleet/outputs/fleet-default-output" \
      -d '{"hosts": ["https://elasticsearch:9200"], "config_yaml": "ssl.verification_mode: certificate\nssl.certificate_authorities: [\"/certs/ca.crt\"]"}'; then
      echo "Failed to update fleet output, exiting..."
      exit 1
    fi
    
    # Check Fleet settings AFTER our changes
    echo "=== Fleet settings AFTER our changes ==="
    curl -s -u "kibana:kibana" --cacert /certs/ca.crt https://kibana:5601/api/fleet/settings | jq .
    
    # Check the agent policy details
    echo "=== Agent Policy Details ==="
    curl -s -u "kibana:kibana" --cacert /certs/ca.crt https://kibana:5601/api/fleet/agent_policies/elastic-policy | jq .
    
    # Check enrollment tokens
    echo "=== Enrollment Tokens ==="
    curl -s -u "kibana:kibana" --cacert /certs/ca.crt https://kibana:5601/api/fleet/enrollment_api_keys | jq '.items[] | select(.policy_id == "elastic-policy")'

    echo "✓ All fleet configuration completed successfully!"
    break
  else
    echo "Waiting for Kibana to be ready..."
    sleep 5
  fi
done
