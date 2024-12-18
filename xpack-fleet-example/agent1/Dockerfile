FROM docker.elastic.co/elastic-agent/elastic-agent:8.12.2

USER root

RUN apt-get update && \
    apt-get install -y curl jq

COPY entrypoint.sh /entrypoint.sh

USER elastic

ENTRYPOINT [ "/entrypoint.sh" ]