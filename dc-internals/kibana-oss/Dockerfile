ARG KIBANA_VERSION

FROM docker.elastic.co/kibana/kibana-oss:$KIBANA_VERSION

ARG KIBANA_PLUGIN_LOCATION

RUN /usr/share/kibana/bin/kibana-plugin --allow-root install "$KIBANA_PLUGIN_LOCATION"
