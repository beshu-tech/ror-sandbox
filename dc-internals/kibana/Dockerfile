ARG KIBANA_VERSION

FROM kibana:$KIBANA_VERSION

ARG KIBANA_PLUGIN_LOCATION

RUN /usr/share/kibana/bin/kibana-plugin --allow-root install "$KIBANA_PLUGIN_LOCATION"
