#!/bin/bash -ex

curl -k -s -f -u "elastic:elastic" \
    -XPOST -H "kbn-xsrf: kibana" -H "Content-type: application/json" \
    "https://kibana:5601/api/fleet/agent_policies" \
    -d '{"id":"elastic-policy","name":"Elastic-Policy","namespace":"default","monitoring_enabled":["logs","metrics"]}'

curl -k -s -f -u "elastic:elastic" \
    -XPOST -H "kbn-xsrf: kibana" -H "Content-type: application/json" \
    "https://kibana:5601/api/fleet/package_policies" \
    -d '{"name":"Elastic-System-package","namespace":"default","policy_id":"elastic-policy", "package":{"name": "system", "version":"1.54.0"}}'

curl -vk -u "elastic:elastic" \
    -XPOST -H "kbn-xsrf: kibana" -H "Content-type: application/json" \
    "https://kibana:5601/api/fleet/package_policies" \
    -d '{"name":"apm2","namespace":"default","policy_id":"elastic-policy", "package":{"name": "apm", "version":"8.12.2"},"inputs":[{"type":"apm","enabled":true,"streams":[],"policy_template":"apmserver","vars":{"host":{"value":"agent1:8200","type":"text"},"url":{"value":"https://agent1:8200","type":"text"},"tls_enabled":{"value":true,"type":"bool"},"tls_certificate":{"value":"/certs/agent1.crt","type":"text"},"tls_key":{"value":"/certs/agent1.key","type":"text"}}}]}'
    
curl -k -s -f -u "elastic:elastic" \
    -XPUT -H "kbn-xsrf: kibana" -H "Content-type: application/json" \
    "https://kibana:5601/api/fleet/settings" \
    -d '{"fleet_server_hosts": ["https://fleet-server:8220"]}'

curl -k -s -f -u "elastic:elastic" \
    -XPUT -H "kbn-xsrf: kibana" -H "Content-type: application/json" \
    "https://kibana:5601/api/fleet/outputs/fleet-default-output" \
    -d '{"hosts": ["https://elasticsearch:9200"], "config_yaml": "ssl.verification_mode: certificate\nssl.certificate_authorities: [\"/certs/ca.crt\"]"}'
 