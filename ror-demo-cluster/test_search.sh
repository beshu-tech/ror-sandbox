#!/bin/bash -e 

curl -v -u user1:test "http://localhost:19200/_search?size=100&pretty" -H "Content-Type: application/json" -d '{"query": {"match_all": {}}}'
