#!/bin/bash -e
# Seeds test indices on the REMOTE cluster during stack init.
# Run by the 'remote-initializer' one-shot service (see docker-compose.yml).
# The remote ROR config is permissive (match-all), so no credentials are needed.

ADDR="${REMOTE_ES_ADDRESS:-https://es-remote:9200}"

# es-remote healthcheck gates this via depends_on, but retry a bit just in case.
for i in $(seq 1 30); do
  if curl -ks "$ADDR/_cluster/health" >/dev/null 2>&1; then break; fi
  echo "waiting for remote ES ($i) ..."
  sleep 5
done

# 'asdasd' is the index the /*:*asdasd/_search test resolves to. The others let
# you probe each ACL pattern independently; 'notmatching' is a negative control.
for idx in asdasd xasdasd asdasdx xasdasdx notmatching; do
  curl -ks -X PUT "$ADDR/$idx" -H 'Content-Type: application/json' -d '{}' >/dev/null || true
  curl -ks -X POST "$ADDR/$idx/_doc?refresh=true" -H 'Content-Type: application/json' -d '{"hello":"world"}' >/dev/null || true
  echo "created remote index: $idx"
done

echo "remote index init done"
