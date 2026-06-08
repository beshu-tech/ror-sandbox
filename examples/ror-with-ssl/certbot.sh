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

# ES runs internally as UID 1000 regardless of the Docker user setting.
# Files created by this container are owned by root, so chown is required
# for ES to be able to read the cert files on Linux.
# All directories need to be traversable by UID 1000, including accounts/ and
# archive/ which certbot creates with restrictive permissions.
find /certs -type d -exec chown 1000 {} \;
chown 1000 /certs/live/$DOMAIN/privkey.pem /certs/live/$DOMAIN/fullchain.pem