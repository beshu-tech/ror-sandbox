#!/bin/bash

# Define variables
KIBANA_URL="http://localhost:15601"
INDEX_PATTERN_TITLE="ror_poc_001"
INDEX_PATTERN_TIME_FIELD="@timestamp"
VISUALIZATION_TITLE="Username Keyword Visualization"
DASHBOARD_TITLE="ROR POC 001 Dashboard"
KIBANA_USER="kibana"
KIBANA_PASSWORD="kibana"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

curl -vk -u kibana:kibana -XPUT "http://localhost:19200/ror_poc_001/_doc/1" -H "Content-type: application/json" -d '{"username": "user1", "@timestamp": "'$TIMESTAMP'"}'
curl -vk -u kibana:kibana -XPUT "http://localhost:19200/ror_poc_001/_doc/2" -H "Content-type: application/json" -d '{"username": "user1", "@timestamp": "'$TIMESTAMP'"}'
curl -vk -u kibana:kibana -XPUT "http://localhost:19200/ror_poc_001/_doc/3" -H "Content-type: application/json" -d '{"username": "user1", "@timestamp": "'$TIMESTAMP'"}'
curl -vk -u kibana:kibana -XPUT "http://localhost:19200/ror_poc_001/_doc/4" -H "Content-type: application/json" -d '{"username": "user2", "@timestamp": "'$TIMESTAMP'"}'
curl -vk -u kibana:kibana -XPUT "http://localhost:19200/ror_poc_001/_doc/5" -H "Content-type: application/json" -d '{"username": "user2", "@timestamp": "'$TIMESTAMP'"}'
curl -vk -u kibana:kibana -XPUT "http://localhost:19200/ror_poc_001/_doc/6" -H "Content-type: application/json" -d '{"username": "user2", "@timestamp": "'$TIMESTAMP'"}'

# Create Index Pattern
INDEX_PATTERN_RESPONSE=$(curl -u "$KIBANA_USER:$KIBANA_PASSWORD" -X POST "$KIBANA_URL/api/saved_objects/index-pattern" -H 'kbn-xsrf: true' -H 'Content-Type: application/json' -d "{
  \"attributes\": {
    \"title\": \"$INDEX_PATTERN_TITLE\",
    \"timeFieldName\": \"$INDEX_PATTERN_TIME_FIELD\"
  }
}")

INDEX_PATTERN_ID=$(echo $INDEX_PATTERN_RESPONSE | jq -r '.id')

# Create Visualization
VISUALIZATION_RESPONSE=$(curl -u "$KIBANA_USER:$KIBANA_PASSWORD" -X POST "$KIBANA_URL/api/saved_objects/lens" -H 'kbn-xsrf: true' -H 'Content-Type: application/json' -d '{"attributes":{"title":"ROR POC Vizualization","description":"","visualizationType":"lnsXY","state":{"visualization":{"legend":{"isVisible":true,"position":"right"},"valueLabels":"hide","fittingFunction":"None","yLeftExtent":{"mode":"full"},"yRightExtent":{"mode":"full"},"axisTitlesVisibilitySettings":{"x":true,"yLeft":true,"yRight":true},"tickLabelsVisibilitySettings":{"x":true,"yLeft":true,"yRight":true},"labelsOrientation":{"x":0,"yLeft":0,"yRight":0},"gridlinesVisibilitySettings":{"x":true,"yLeft":true,"yRight":true},"preferredSeriesType":"bar_stacked","layers":[{"layerId":"dbf664d8-92b8-4d48-8735-27f59ddbfb55","accessors":["baee8dad-44c2-4569-aae3-f519ca362087"],"position":"top","seriesType":"bar_stacked","showGridlines":false,"layerType":"data","xAccessor":"a4dd85e5-e343-4e3e-bd90-1eb6d213ecca"}]},"query":{"query":"","language":"kuery"},"filters":[],"datasourceStates":{"indexpattern":{"layers":{"dbf664d8-92b8-4d48-8735-27f59ddbfb55":{"columns":{"a4dd85e5-e343-4e3e-bd90-1eb6d213ecca":{"label":"Top values of username.keyword","dataType":"string","operationType":"terms","scale":"ordinal","sourceField":"username.keyword","isBucketed":true,"params":{"size":5,"orderBy":{"type":"column","columnId":"baee8dad-44c2-4569-aae3-f519ca362087"},"orderDirection":"desc","otherBucket":true,"missingBucket":false}},"baee8dad-44c2-4569-aae3-f519ca362087":{"label":"Count of records","dataType":"number","operationType":"count","isBucketed":false,"scale":"ratio","sourceField":"username.keyword"}},"columnOrder":["a4dd85e5-e343-4e3e-bd90-1eb6d213ecca","baee8dad-44c2-4569-aae3-f519ca362087"],"incompleteColumns":{}}}}}}},"references":[{"type":"index-pattern","id":"'$INDEX_PATTERN_ID'","name":"indexpattern-datasource-current-indexpattern"},{"type":"index-pattern","id":"'$INDEX_PATTERN_ID'","name":"indexpattern-datasource-layer-dbf664d8-92b8-4d48-8735-27f59ddbfb55"}]}')

# Extract the visualization ID
VISUALIZATION_ID=$(echo $VISUALIZATION_RESPONSE | jq -r '.id')


# Create Dashboard
curl -u "$KIBANA_USER:$KIBANA_PASSWORD" -X POST "$KIBANA_URL/api/saved_objects/dashboard/ror_poc?overwrite=true" -H 'kbn-xsrf: true' -H 'Content-Type: application/json' -d '{"attributes":{"title":"ROR POC Dashboard","hits":0,"description":"","panelsJSON":"[{\"version\":\"7.17.15\",\"type\":\"lens\",\"gridData\":{\"x\":0,\"y\":0,\"w\":24,\"h\":15,\"i\":\"7aa7d817-921c-46c8-9b65-ab22353a4bc9\"},\"panelIndex\":\"7aa7d817-921c-46c8-9b65-ab22353a4bc9\",\"embeddableConfig\":{\"enhancements\":{}},\"panelRefName\":\"panel_7aa7d817-921c-46c8-9b65-ab22353a4bc9\"}]","optionsJSON":"{\"useMargins\":true,\"syncColors\":false,\"hidePanelTitles\":false}","version":1,"timeRestore":false,"kibanaSavedObjectMeta":{"searchSourceJSON":"{\"query\":{\"query\":\"\",\"language\":\"kuery\"},\"filter\":[]}"}},"references":[{"name":"7aa7d817-921c-46c8-9b65-ab22353a4bc9:panel_7aa7d817-921c-46c8-9b65-ab22353a4bc9","type":"lens","id":"'$VISUALIZATION_ID'"}]}'


