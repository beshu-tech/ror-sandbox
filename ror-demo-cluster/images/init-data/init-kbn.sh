#!/bin/bash -ex

import_saved_obj () {
    local USR=$1
    local PASS=$2
    DEST_ID=$(curl -s -u "$USR":"$PASS" -XPOST -H "kbn-xsrf: true" "http://kbn-ror:5601/api/saved_objects/_import?createNewCopies=false" --form file=@export-ror-$USR.ndjson | jq -r .successResults[0].id)
    echo "$DEST_ID"
}

run_report () {
    local USR=$1
    local PASS=$2
    local DEST_ID=$3
    curl -fvk -u "$USR":"$PASS" -XPOST -H "kbn-xsrf: true" "http://kbn-ror:5601/api/reporting/generate/csv_searchsource?jobParams=%28browserTimezone%3AEurope%2FWarsaw%2Ccolumns%3A%21%28%29%2CobjectType%3Asearch%2CsearchSource%3A%28fields%3A%21%28%28field%3A%27%2A%27%2Cinclude_unmapped%3Atrue%29%29%2Cfilter%3A%21%28%29%2Cindex%3A$DEST_ID%2Cquery%3A%28language%3Akuery%2Cquery%3A%27%27%29%2Csort%3A%21%28%28_score%3Adesc%29%29%29%2Ctitle%3Asearch-data-view-example-$USR%2Cversion%3A%278.11.3%27%29"
}


DEST_ID=$(import_saved_obj "user1" "test")
sleep 5
for i in $(seq 0 3); do
    run_report "user1" "test" "$DEST_ID"
done

DEST_ID=$(import_saved_obj "user2" "test")
sleep 5
for i in $(seq 0 5); do
    run_report "user2" "test" "$DEST_ID"
done
