ARG ES_VERSION="please_set_ES_VERSION_arg"
ARG ROR_ES_VERSION="please_set_ROR_ES_VERSION_arg"

FROM beshultd/elasticsearch-readonlyrest:${ES_VERSION}-ror-${ROR_ES_VERSION}

USER root
COPY conf/es/readonlyrest.yml /usr/share/elasticsearch/config/readonlyrest.yml
COPY conf/es/elasticsearch.yml /usr/share/elasticsearch/config/elasticsearch.yml
COPY conf/es/ca.crt /usr/share/elasticsearch/config/ca.crt
COPY conf/es/elasticsearch.crt /usr/share/elasticsearch/config/elasticsearch.crt
COPY conf/es/elasticsearch.key /usr/share/elasticsearch/config/elasticsearch.key
RUN chown -R elasticsearch:elasticsearch /usr/share/elasticsearch/config

ENV I_UNDERSTAND_IMPLICATION_OF_ES_PATCHING=yes
# stay as root — official image's entrypoint patches ES then drops to elasticsearch user
