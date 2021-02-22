ARG ELASTICSEARCH_VERSION

FROM elasticsearch:$ELASTICSEARCH_VERSION

ARG ELASTICSEARCH_LOCATION

RUN /usr/share/elasticsearch/bin/elasticsearch-plugin install -b "$ELASTICSEARCH_LOCATION"

