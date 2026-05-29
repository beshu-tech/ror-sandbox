ARG KBN_VERSION="please_set_KBN_VERSION_arg"
ARG ROR_KBN_VERSION="please_set_ROR_KBN_VERSION_arg"

FROM beshultd/kibana-readonlyrest:${KBN_VERSION}-ror-${ROR_KBN_VERSION}

USER root
COPY conf/kbn/kibana.yml /usr/share/kibana/config/kibana.yml
RUN chown -R kibana:kibana /usr/share/kibana/config \
 && chmod 664 /usr/share/kibana/config/kibana.yml

ENV I_UNDERSTAND_AND_ACCEPT_KBN_PATCHING=yes
# stay as root — official image's entrypoint patches Kibana then drops to kibana user
