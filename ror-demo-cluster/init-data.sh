#!/bin/bash

for i in $(seq 0 10); do
    curl -vk -u kibana:kibana -XPUT "http://localhost:19200/index-1/_doc/$i" -H "Content-type: application/json" -d '{"df_country": "UK", "price": 100, "df_date": "2023-12-21T11:47:22.992000"}'
done

for i in $(seq 0 10); do
    curl -vk -u kibana:kibana -XPUT "http://localhost:19200/index-2/_doc/$i" -H "Content-type: application/json" -d '{"df_country": "UK", "price": 100, "df_date": "2023-12-21T11:47:22.992000"}'
done

for i in $(seq 0 10); do
    curl -vk -u kibana:kibana -XPUT "http://localhost:19200/index-3/_doc/$i" -H "Content-type: application/json" -d '{"df_country": "UK", "price": 100, "df_date": "2023-12-21T11:47:22.992000"}'
done

for i in $(seq 0 10); do
    curl -vk -u kibana:kibana -XPUT "http://localhost:19200/index-4/_doc/$i" -H "Content-type: application/json" -d '{"df_country": "UK", "price": 100, "df_date": "2023-12-21T11:47:22.992000"}'
done

for i in $(seq 0 10); do
    curl -vk -u kibana:kibana -XPUT "http://localhost:19200/index-5/_doc/$i" -H "Content-type: application/json" -d '{"df_country": "UK", "price": 100, "df_date": "2023-12-21T11:47:22.992000"}'
done