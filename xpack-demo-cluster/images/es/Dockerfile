ARG ES_VERSION

FROM docker.elastic.co/elasticsearch/elasticsearch:${ES_VERSION}

ARG ES_VERSION

USER elasticsearch
COPY conf/elasticsearch.yml /usr/share/elasticsearch/config/elasticsearch.yml
COPY conf/log4j2.properties /usr/share/elasticsearch/config/log4j2.properties
COPY conf/elastic-certificates.p12 /usr/share/elasticsearch/config/elastic-certificates.p12

# RUN echo "" | /usr/share/elasticsearch/bin/elasticsearch-keystore create &&\
#     echo 'elastic' | /usr/share/elasticsearch/bin/elasticsearch-keystore add --stdin bootstrap.password -f  &&\
#     printf 'readonlyrest' | /usr/share/elasticsearch/bin/elasticsearch-keystore add xpack.security.http.ssl.keystore.secure_password &&\
#     printf 'readonlyrest' | /usr/share/elasticsearch/bin/elasticsearch-keystore add xpack.security.http.ssl.truststore.secure_password &&\
#     printf 'readonlyrest' | /usr/share/elasticsearch/bin/elasticsearch-keystore add xpack.security.transport.ssl.keystore.secure_password &&\
#     printf 'readonlyrest' | /usr/share/elasticsearch/bin/elasticsearch-keystore add xpack.security.transport.ssl.truststore.secure_password