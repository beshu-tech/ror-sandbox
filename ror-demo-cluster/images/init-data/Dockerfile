FROM ubuntu:22.04

RUN \
  apt-get update \
  && apt-get -y install jq curl \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* 

COPY images/init-data/export-ror-user1.ndjson /tmp/export-ror-user1.ndjson
COPY images/init-data/export-ror-user2.ndjson /tmp/export-ror-user2.ndjson
COPY images/init-data/init-es.sh /tmp/init-es.sh
COPY images/init-data/init-kbn.sh /tmp/init-kbn.sh
COPY images/init-data/init.sh /tmp/init.sh

ENTRYPOINT ["/tmp/init.sh"]