ARG KBN_VERSION

FROM docker.elastic.co/kibana/kibana:${KBN_VERSION}

ARG KBN_VERSION

USER root
RUN chown -R kibana:kibana /usr/share/kibana/config

USER kibana
COPY conf/kibana.yml /usr/share/kibana/config/kibana.yml
