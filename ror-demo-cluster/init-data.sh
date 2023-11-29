#!/bin/bash -e

for i in $(seq 0 100); do
    curl -v -u "admin:admin" "http://localhost:19200/example/_doc/$i" -XPOST -H "Content-Type: application/json" -d '{"id": 1}'
done