#!/bin/bash 

curl -vk -u elastic:elastic -XPUT "http://localhost:25601/api/security/role/bsp1_viewer" -H "kbn-xsrf: reporting" -H "Content-type: application/json" -d '{"metadata":{},"elasticsearch":{"cluster":[],"indices":[{"names":["crm-bsp1_001"],"privileges":["read"],"allow_restricted_indices":false}],"run_as":[]},"kibana":[{"spaces":["*"],"base":["all"],"feature":{}}]}'
curl -vk -u elastic:elastic -XPUT "https://localhost:29200/_security/user/bsp1" -H "Content-type: application/json" -d '{"password":"testtest", "roles":["bsp1_viewer","viewer","reporting_user","kibana_user"]}'

curl -vk -u elastic:elastic -XPUT "http://localhost:35601/api/security/role/bsp2_viewer" -H "kbn-xsrf: reporting" -H "Content-type: application/json" -d '{"metadata":{},"elasticsearch":{"cluster":[],"indices":[{"names":["crm-bsp2_001"],"privileges":["read"],"allow_restricted_indices":false}],"run_as":[]},"kibana":[{"spaces":["*"],"base":["all"],"feature":{}}]}'
curl -vk -u elastic:elastic -XPUT "https://localhost:29200/_security/user/bsp2" -H "Content-type: application/json" -d '{"password":"testtest", "roles":["bsp2_viewer","viewer","reporting_user","kibana_user"]}'

