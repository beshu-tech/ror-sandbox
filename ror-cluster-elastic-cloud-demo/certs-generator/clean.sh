#!/bin/bash -e

docker-compose --file generate-certs-docker-compose.base.yml down -v
rm -rf output input