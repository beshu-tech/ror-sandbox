#!/bin/bash -e

rm -rf ca
mkdir -p ca
openssl req -x509 \
    -newkey rsa:4096 \
    -keyout ca/ca.key \
    -out ca/ca.crt \
    -sha256 -days 3650 \
    -nodes \
    -subj "/C=GB/ST=London/L=London/O=Beshu/OU=IT/CN=readonlyrest.beshu.tech"

mkdir -p certs
cp ca/ca.crt certs