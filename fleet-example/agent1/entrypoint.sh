#!/bin/bash -e

FLEET_ENROLLMENT_TOKEN=$(curl -k -s \
  -u elastic:elastic \
  https://kibana:5601/api/fleet/enrollment_api_keys | \
  jq -r '.items[] | select(any(.; .policy_id == "elastic-policy")) | .api_key')

if [[ -z "$ENROLLMENT_TOKEN" ]]; then
  echo "Failed to retrieve enrollment token for policy_id: $POLICY_ID" >&2
  exit 1
fi

export FLEET_ENROLLMENT_TOKEN

/usr/local/bin/docker-entrypoint