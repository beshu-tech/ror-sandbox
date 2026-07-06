#!/bin/bash
# Cross-cluster search test helper for the RORDEV-2109 investigation.
#
# Prereqs: `./run.sh` is up and healthy (es-ror + es-remote both running).
#
# It:
#   1. creates real indices on the REMOTE cluster,
#   2. shows that the main cluster sees the remote as connected,
#   3. fires the 4 Test blocks (request index is always `*:*asdasd`).
#
# Compare against the no-remote-cluster run: previously every block returned
# IDX_NOT_FOUND because ROR rewrote `*:*asdasd` into a nonexistent local index
# (skipRemoteIndicesIfNeeded). With a remote cluster configured, `*:*asdasd`
# now resolves against the real remote indices below.

set -euo pipefail

MAIN="https://127.0.0.1:19200"
REMOTE="https://127.0.0.1:29200"

echo "== 1. Create test indices on the REMOTE cluster (remote1) =="
# 'asdasd' is the one matched by the request `*:*asdasd`. The others let you
# probe the four ACL patterns independently if you change the request.
for idx in asdasd xasdasd asdasdx xasdasdx notmatching; do
  curl -ks -X PUT "$REMOTE/$idx" -H 'Content-Type: application/json' -d '{}' >/dev/null || true
  curl -ks -X POST "$REMOTE/$idx/_doc?refresh=true" -H 'Content-Type: application/json' -d '{"hello":"world"}' >/dev/null || true
  echo "  created remote index: $idx"
done

echo
echo "== 2. Remote cluster connection status (as seen by the MAIN cluster) =="
curl -ks -u admin:admin "$MAIN/_remote/info?pretty" || true

echo
echo "== 3. Fire the 4 Test blocks — request index is always /*:*asdasd/_search =="
echo "   (Test1 indices:[*:asdasd]  Test2:[*:*asdasd]  Test3:[*:asdasd*]  Test4:[*:*asdasd*])"
for x in 1 2 3 4; do
  code=$(curl -ks -u user:test "$MAIN/*:*asdasd/_search" -H "test:$x" -o /dev/null -w "%{http_code}")
  hits=$(curl -ks -u user:test "$MAIN/*:*asdasd/_search" -H "test:$x" | grep -o '"total":{"value":[0-9]*' | head -1 || true)
  echo "  Test$x -> HTTP $code   $hits"
done

echo
echo "Done. HTTP 200 means the indices rule matched (block allowed the request);"
echo "HTTP 403/401 or an IDX_NOT_FOUND in ror-cluster.log means it did not."
