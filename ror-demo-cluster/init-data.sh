#!/bin/bash -e

# create indices
file="indices.txt"
while IFS= read -r line; do
  curl -vk -u kibana:kibana -XPUT "https://localhost:19200/$line"
done < "$file"

# create repository "data"
curl -vk -u kibana:kibana -XPUT "https://localhost:19200/_snapshot/data" \
  -H "Content-Type: application/json" -d '{"type": "fs","settings": {"location": "/tmp"}}'