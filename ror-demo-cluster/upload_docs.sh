#!/bin/bash -e

for i in {1..40}; do
    curl -u admin:admin -XPOST "http://localhost:19200/test01/_doc/$i" -H "Content-Type: application/json" -d '{"user1":"a", "user2":"b", "user3":"c"}'
done