#!/bin/bash -e

curl -k -s -f -u "elastic:elastic" \
    -XPOST -H "kbn-xsrf: kibana" -H "Content-type: application/json" \
    "https://kibana:5601/api/fleet/agent_policies" \
    -d '{"id":"elastic-policy","name":"Elastic-Policy","namespace":"default","monitoring_enabled":["logs","metrics"]}'

curl -k -s -f -u "elastic:elastic" \
    -XPOST -H "kbn-xsrf: kibana" -H "Content-type: application/json" \
    "https://kibana:5601/api/fleet/package_policies" \
    -d '{"name":"Elastic-System-package","namespace":"default","policy_id":"elastic-policy", "package":{"name": "system", "version":"1.54.0"}}'

curl -k -s -f -u "elastic:elastic" \
    -XPUT -H "kbn-xsrf: kibana" -H "Content-type: application/json" \
    "https://kibana:5601/api/fleet/settings" \
    -d '{"fleet_server_hosts": ["https://fleet-server:8220"]}'

curl -k -s -f -u "elastic:elastic" \
    -XPUT -H "kbn-xsrf: kibana" -H "Content-type: application/json" \
    "https://kibana:5601/api/fleet/outputs/fleet-default-output" \
    -d '{"hosts": ["https://elasticsearch:9200"], "config_yaml": "ssl.verification_mode: certificate\nssl.certificate_authorities: [\"/certs/ca.crt\"]"}'
