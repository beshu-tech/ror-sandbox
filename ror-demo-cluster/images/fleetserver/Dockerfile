FROM ubuntu:24.10

RUN apt-get update && \
    apt-get install -y libc6-amd64-cross vim curl npm && \
    ln -s /usr/x86_64-linux-gnu/lib64/ /lib64 

RUN mkdir -p /fleet && \
    cd /fleet && \
    curl -L -O https://artifacts.elastic.co/downloads/beats/elastic-agent/elastic-agent-8.14.3-linux-x86_64.tar.gz && \
    tar xzvf elastic-agent-8.14.3-linux-x86_64.tar.gz && \
    cd elastic-agent-8.14.3-linux-x86_64

ENV LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/lib64:/usr/x86_64-linux-gnu/lib"

# ./elastic-agent install \
#   --fleet-server-es=http://es-ror:9200 \
#   --fleet-server-service-token=AAEAAWVsYXN0aWMvZmxlZXQtc2VydmVyL3Rva2VuLTE3MzI5MDI1NDY4MTk6ZjNhdk1Pa2ZTaGFEZl9YamotSTlUUQ \
#   --fleet-server-policy=fleet-server-policy \
#   --fleet-server-port=8220