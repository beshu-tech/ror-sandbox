ARG KIBANA_VERSION

FROM kibana:$KIBANA_VERSION

ARG KIBANA_PLUGIN_LOCATION

RUN /usr/share/kibana/bin/kibana-plugin install "$KIBANA_PLUGIN_LOCATION"

RUN if [ -f "/usr/share/kibana/plugins/readonlyrestkbn/ror-tools.js" ]; then node/bin/node plugins/readonlyrestkbn/ror-tools.js patch; fi;
