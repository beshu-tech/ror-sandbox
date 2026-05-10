#!/bin/sh
set -e

apk add --no-cache curl openssl

# Get Pebble CA chain
curl -k https://pebble:15000/roots/0 > /tmp/root.pem
curl -k https://pebble:15000/intermediates/0 > /tmp/intermediate.pem
cat /tmp/root.pem /tmp/intermediate.pem > /tmp/ca-chain.pem

# Add domain to hosts
ES_IP=$(getent hosts es-ror | awk '{print $1}')
echo "$ES_IP $DOMAIN" >> /etc/hosts

echo "=== Certificate Chain ==="
openssl s_client -connect $DOMAIN:9200 \
  -CAfile /tmp/ca-chain.pem \
  2>/dev/null | openssl x509 -noout -text \
  | grep -E "Issuer|Subject|Not Before|Not After|DNS"

echo "=== Chain Verification ==="
VERIFY_OUTPUT=$(openssl s_client -connect $DOMAIN:9200 \
  -CAfile /tmp/ca-chain.pem \
  2>&1)

echo "$VERIFY_OUTPUT" | grep -E "verify|Verify"

CHAIN_DEPTH=$(echo "$VERIFY_OUTPUT" | grep -c "verify return:1")
echo "Chain depth: $CHAIN_DEPTH"

if [ "$CHAIN_DEPTH" -lt 3 ]; then
  echo "=== TEST FAILED: incomplete chain, only $CHAIN_DEPTH level(s) - server may be using cert.pem instead of fullchain.pem ==="
  exit 1
fi

echo "=== Strict Chain Verification ==="

set +e
curl -v -s \
  -o /tmp/response.json \
  -w "%{http_code}" \
  --stderr /tmp/curl-verbose.log \
  --cacert /tmp/root.pem \
  -u admin:admin \
  https://$DOMAIN:9200/_cluster/health \
  > /tmp/http-code.txt
CURL_EXIT=$?
set -e


echo "=== Curl verbose log ==="
cat /tmp/curl-verbose.log

echo "Curl exit code: $CURL_EXIT"

if [ "$CURL_EXIT" != "0" ]; then
  echo "=== TEST FAILED: curl failed with exit code $CURL_EXIT ==="
  exit 1
fi

echo "=== Response body ==="
cat /tmp/response.json
echo ""

HTTP_CODE=$(cat /tmp/http-code.txt)
echo "HTTP code: $HTTP_CODE"

if [ "$HTTP_CODE" != "200" ]; then
  echo "=== TEST FAILED: ES returned unexpected HTTP code $HTTP_CODE ==="
  exit 1
fi

echo "=== TEST PASSED ==="