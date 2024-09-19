#!/bin/bash -e

USER=$1
PASS=$2
ES_HOST=https://localhost:19200
SNAPSHOT_ID=$(date +%s)

curl -kv -u ${USER}:${PASS} -X PUT "${ES_HOST}/_snapshot/data/test_snapshot_${SNAPSHOT_ID}" \
    -H "Content-Type: application/json" \
    -d '{
          "indices": [
            "-operate-user-task-8.5.0_",
            "-operate-event-8.3.0_",
            "operate-user-task-8.5.0_*",
            "-operate-variable-8.3.0_",
            "operate-event-8.3.0_*",
            "operate-variable-8.3.0_*"
          ],
          "include_global_state": true
        }'