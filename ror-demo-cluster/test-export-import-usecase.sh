#!/bin/bash -ex

KIBANA_URL="https://localhost:15601"
CREDENTIALS="admin:admin"

EXISTING_DASHBOARD_ID=$(
  curl -ks -u "$CREDENTIALS" -H "x-ror-tenancy-id: Administrators" \
    "$KIBANA_URL/api/saved_objects/_find?type=dashboard" | jq -r '.saved_objects[0].id'
)
EXPORTED_DASHBOARD_JSON=$(
  curl -ks -u "$CREDENTIALS" -H "x-ror-tenancy-id: Administrators" \
    "$KIBANA_URL/api/kibana/dashboards/export?dashboard=$EXISTING_DASHBOARD_ID"
)

curl -ks -u "$CREDENTIALS" -H "x-ror-tenancy-id: BusinessUsers" \
  -XPOST "https://localhost:15601/api/kibana/dashboards/import?exclude=index-pattern" -H "kbn-xsrf: true" \
  -H "Content-Type: application/json" -d "$EXPORTED_DASHBOARD_JSON"