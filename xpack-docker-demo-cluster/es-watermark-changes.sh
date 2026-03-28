#!/bin/bash
# Script to set Elasticsearch disk watermarks dynamically

ES_URL="https://localhost:29200"
AUTH="elastic:elastic"

# Set transient disk watermarks
curl -k -u $AUTH -X PUT "$ES_URL/_cluster/settings" \
  -H "Content-Type: application/json" \
  -d '{
    "transient": {
      "cluster.routing.allocation.disk.watermark.low": "5%",
      "cluster.routing.allocation.disk.watermark.high": "10%",
      "cluster.routing.allocation.disk.watermark.flood_stage": "15%"
    }
  }'
