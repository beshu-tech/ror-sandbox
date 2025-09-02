#!/bin/bash -e

docker compose -f docker-compose.base.yml \
               -f docker-compose.enterprise.yml \
               -f docker-compose.pro.yml \
               -f docker-compose.free.yml \
               rm --stop --force