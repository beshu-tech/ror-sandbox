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
    curl -fvk -u "$USR":"$PASS" -XPOST -H 'kbn-xsrf: true' "http://kbn-ror:5601/api/reporting/generate/csv?jobParams=%28browserTimezone%3AEurope%2FWarsaw%2CconflictedTypesFields%3A%21%28%29%2Cfields%3A%21%28_id%2C_index%2C_score%2C_type%2Cid%29%2CindexPatternId%3A$DEST_ID%2CmetaFields%3A%21%28_source%2C_id%2C_type%2C_index%2C_score%29%2CobjectType%3Asearch%2CsearchRequest%3A%28body%3A%28_source%3A%21f%2Cfields%3A%21%28%28field%3A%27%2A%27%2Cinclude_unmapped%3Atrue%29%29%2Cquery%3A%28bool%3A%28filter%3A%21%28%28match_all%3A%28%29%29%29%2Cmust%3A%21%28%29%2Cmust_not%3A%21%28%29%2Cshould%3A%21%28%29%29%29%2Cruntime_mappings%3A%28%29%2Cscript_fields%3A%28%29%2Csort%3A%21%28%28_score%3A%28order%3Adesc%29%29%29%2Cstored_fields%3A%21%28%27%2A%27%29%2Cversion%3A%21t%29%2Cindex%3A%27ex%2A%27%29%2Ctitle%3Asearch-data-view-example-$USR%29"
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
