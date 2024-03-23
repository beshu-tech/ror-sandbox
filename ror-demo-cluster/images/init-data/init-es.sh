#!/bin/bash -e

for i in $(seq 0 100); do
    curl -v -u "admin:admin" "http://es-ror:9200/example/_doc/$i" -XPOST -H "Content-Type: application/json" -d "{\"id\": $i}"
done