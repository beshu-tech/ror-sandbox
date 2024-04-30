#!/bin/bash

for i in $(seq 0 10); do
    curl -vk -u kibana:kibana -XPUT "http://localhost:19200/example/_doc/$i" -H "Content-type: application/json" -d '{"user_field": "user1", "df_country": "UK", "price": 100, "df_date": "2023-12-21T11:47:22.992000"}'
done
for i in $(seq 11 20); do
    curl -vk -u kibana:kibana -XPUT "http://localhost:19200/example/_doc/$i" -H "Content-type: application/json" -d '{"user_field": "user2", "df_country": "PL", "price": 80, "df_date": "2023-12-21T11:47:22.992000"}'
done