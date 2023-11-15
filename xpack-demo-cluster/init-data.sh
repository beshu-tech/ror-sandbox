#!/bin/bash 

curl -vk -u elastic:elastic -XPUT "https://localhost:29200/crm-bsp1_001/_doc/1" -H "Content-type: application/json" -d '{"DestCountry": "PL"}'
curl -vk -u elastic:elastic -XPUT "https://localhost:29200/crm-bsp1_001/_doc/2" -H "Content-type: application/json" -d '{"DestCountry": "PL"}'
curl -vk -u elastic:elastic -XPUT "https://localhost:29200/crm-bsp1_001/_doc/3" -H "Content-type: application/json" -d '{"DestCountry": "PL"}'

curl -vk -u elastic:elastic -XPUT "https://localhost:29200/crm-bsp2_001/_doc/1" -H "Content-type: application/json" -d '{"DestCountry": "CZ"}'
curl -vk -u elastic:elastic -XPUT "https://localhost:29200/crm-bsp2_001/_doc/2" -H "Content-type: application/json" -d '{"DestCountry": "CZ"}'
curl -vk -u elastic:elastic -XPUT "https://localhost:29200/crm-bsp2_001/_doc/3" -H "Content-type: application/json" -d '{"DestCountry": "CZ"}'
