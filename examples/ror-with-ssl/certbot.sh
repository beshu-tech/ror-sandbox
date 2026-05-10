#!/bin/sh
set -e

# clean old certs
rm -rf /certs/*

certbot certonly \
  --standalone \
  --server $CA_URL \
  --no-verify-ssl \
  --email test@test.com \
  --agree-tos \
  --non-interactive \
  --config-dir /certs \
  --force-renewal \
  -d $DOMAIN