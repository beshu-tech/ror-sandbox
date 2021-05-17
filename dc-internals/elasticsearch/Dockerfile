ARG ELASTICSEARCH_VERSION

FROM elasticsearch:$ELASTICSEARCH_VERSION

ARG ELASTICSEARCH_LOCATION

RUN echo "-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:8888" >> /usr/share/elasticsearch/config/jvm.options

RUN /usr/share/elasticsearch/bin/elasticsearch-plugin install -b "$ELASTICSEARCH_LOCATION"
