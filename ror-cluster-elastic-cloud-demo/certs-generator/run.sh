#!/bin/bash -e

rm -rf output
mkdir output
docker-compose --file generate-certs-docker-compose.base.yml up --build --no-deps