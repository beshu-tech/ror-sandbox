FROM openjdk:11-jdk-slim

ENV KEYCLOAK_VERSION=12.0.4 \
    KEYCLOAK_HOME=/opt/keycloak

RUN apt-get update && apt-get install -y --no-install-recommends curl unzip bash ca-certificates && rm -rf /var/lib/apt/lists/* \
 && useradd -ms /bin/bash keycloak \
 && mkdir -p /opt \
 && curl -fsSL -o /tmp/keycloak.tar.gz https://github.com/keycloak/keycloak/releases/download/${KEYCLOAK_VERSION}/keycloak-${KEYCLOAK_VERSION}.tar.gz \
 && tar -xzf /tmp/keycloak.tar.gz -C /opt \
 && mv /opt/keycloak-${KEYCLOAK_VERSION} ${KEYCLOAK_HOME} \
 && rm /tmp/keycloak.tar.gz \
 && chown -R keycloak:keycloak ${KEYCLOAK_HOME}

WORKDIR ${KEYCLOAK_HOME}

COPY docker-entrypoint.sh ${KEYCLOAK_HOME}/docker-entrypoint.sh
RUN chmod +x ${KEYCLOAK_HOME}/docker-entrypoint.sh && chown keycloak:keycloak ${KEYCLOAK_HOME}/docker-entrypoint.sh

EXPOSE 8080
USER keycloak
ENTRYPOINT ["/opt/keycloak/docker-entrypoint.sh"]
