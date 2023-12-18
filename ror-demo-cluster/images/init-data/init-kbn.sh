#!/bin/bash -e

export DEST_ID=$(curl -s -u kibana:kibana -XPOST -H "kbn-xsrf: true" "http://kbn-ror:5601/api/saved_objects/_import?createNewCopies=true" --form file=@export-ror.ndjson | jq .successResults[0].destinationId)

run_report () {
    local USR=$1
    local PASS=$2
    curl -vk -u "$USR":"$PASS" -XPOST -H "kbn-xsrf: true" "http://kbn-ror:5601/api/reporting/generate/csv_searchsource?jobParams=%28browserTimezone%3AEurope%2FWarsaw%2Ccolumns%3A%21%28%29%2CobjectType%3Asearch%2CsearchSource%3A%28fields%3A%21%28%28field%3A%27%2A%27%2Cinclude_unmapped%3Atrue%29%29%2Cfilter%3A%21%28%29%2Cindex%3A%27$DEST_ID%27%2Cquery%3A%28language%3Akuery%2Cquery%3A%27%27%29%2Csort%3A%21%28%28_score%3Adesc%29%29%29%2Ctitle%3Asearch-example%2Cversion%3A%278.11.3%27%29"
}

for i in $(seq 0 10); do
    run_report "user1" "test"
    run_report "user2" "test"
done
