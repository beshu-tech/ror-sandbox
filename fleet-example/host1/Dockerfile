FROM ubuntu:24.10

RUN apt-get update && \
    apt-get install -y libc6-amd64-cross vim curl npm jq && \
    ln -s /usr/x86_64-linux-gnu/lib64/ /lib64 

RUN mkdir -p /fleet && \
    cd /fleet && \
    curl -L -O https://artifacts.elastic.co/downloads/beats/elastic-agent/elastic-agent-8.12.2-linux-x86_64.tar.gz && \
    tar xzvf elastic-agent-8.12.2-linux-x86_64.tar.gz && \
    cd elastic-agent-8.12.2-linux-x86_64

ENV LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/lib64:/usr/x86_64-linux-gnu/lib"
