#!/bin/bash -e

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <service-name>"
  exit 1
fi

SERVICE=$1

openssl genrsa -out "certs/$SERVICE.key" 2048
openssl req -new -key "certs/$SERVICE.key" -out "certs/$SERVICE.csr" -subj "/C=GB/ST=London/L=London/O=Beshu/OU=IT/CN=$SERVICE" 
openssl x509 -req \
  -in "certs/$SERVICE.csr" \
  -CAkey ca/ca.key \
  -CA ca/ca.crt \
  -CAcreateserial \
  -out "certs/$SERVICE.crt" \
  -days 3650 \
  -sha256 \
  -extfile <(printf "subjectAltName=DNS:$SERVICE,DNS:localhost\nextendedKeyUsage=serverAuth,clientAuth\nkeyUsage=digitalSignature,keyEncipherment,keyAgreement\nsubjectKeyIdentifier=hash")