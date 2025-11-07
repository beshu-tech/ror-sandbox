FROM ubuntu:24.04

ARG TARGETARCH
ENV DEBIAN_FRONTEND=noninteractive EA_VER=8.14.3

RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates curl \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /fleet

RUN set -eux; \
  case "${TARGETARCH:-$(dpkg --print-architecture)}" in \
    amd64)  EA_ARCH=x86_64 ;; \
    arm64|aarch64) EA_ARCH=arm64 ;; \
    *) echo "Unsupported arch"; exit 1 ;; \
  esac; \
  EA_VER=8.14.3; \
  EA_FILE="elastic-agent-${EA_VER}-linux-${EA_ARCH}.tar.gz"; \
  curl -fSL -o "${EA_FILE}" "https://artifacts.elastic.co/downloads/beats/elastic-agent/${EA_FILE}"; \
  tar xzf "${EA_FILE}"; \
  ln -s "elastic-agent-${EA_VER}-linux-${EA_ARCH}" elastic-agent

# ./elastic-agent install \
#   --fleet-server-es=http://es-ror:9200 \
#   --fleet-server-service-token=AAEAAWVsYXN0aWMvZmxlZXQtc2VydmVyL3Rva2VuLTE3MzI5MDI1NDY4MTk6ZjNhdk1Pa2ZTaGFEZl9YamotSTlUUQ \
#   --fleet-server-policy=fleet-server-policy \
#   --fleet-server-port=8220