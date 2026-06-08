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

chown 1000 /certs/live/$DOMAIN /certs/archive /certs/archive/$DOMAIN
chown 1000 /certs/live/$DOMAIN/privkey.pem /certs/live/$DOMAIN/fullchain.pem