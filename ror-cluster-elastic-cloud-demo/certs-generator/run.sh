#!/bin/bash -e

rm -rf output
mkdir output
docker-compose --file generate-certs-docker-compose.yml up --build --no-deps