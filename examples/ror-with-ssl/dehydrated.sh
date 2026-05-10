#!/bin/sh
set -e

# clean old certs
rm -rf /certs/*

apk add --no-cache curl openssl bash

curl -Lo /usr/local/bin/dehydrated \
  https://raw.githubusercontent.com/dehydrated-io/dehydrated/v0.7.2/dehydrated
chmod +x /usr/local/bin/dehydrated

mkdir -p /var/www/dehydrated
printf 'CA_CERT=""\nCURL_OPTS="--insecure"\n' > /tmp/dehydrated.config

dehydrated \
  --register --accept-terms \
  --ca $CA_URL \
  --config /tmp/dehydrated.config

dehydrated \
  --cron \
  --domain $DOMAIN \
  --ca $CA_URL \
  --challenge http-01 \
  --out /certs \
  --config /tmp/dehydrated.config

# create copy in pkcs8 format
CERT_DIR=$(find /certs -name "privkey.pem" -not -path "*/accounts/*" | head -1 | xargs dirname)
openssl pkcs8 -topk8 -nocrypt \
  -in $CERT_DIR/privkey.pem \
  -out $CERT_DIR/privkey-pkcs8.pem