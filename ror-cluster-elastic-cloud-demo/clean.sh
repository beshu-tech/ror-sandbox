#!/bin/bash -e

cd certs-generator
./clean.sh
cd ..
docker-compose rm --stop --force
rm -rf certs