#!/bin/bash
set -euo pipefail
KEYCLOAK_HOME=${KEYCLOAK_HOME:-/opt/keycloak}

if [[ -n "${KEYCLOAK_USER:-}" && -n "${KEYCLOAK_PASSWORD:-}" ]]; then
  echo "Creating admin user" >&2
  ${KEYCLOAK_HOME}/bin/add-user-keycloak.sh -u "${KEYCLOAK_USER}" -p "${KEYCLOAK_PASSWORD}" || true
fi

IMPORT_ARG=""
if [[ -n "${KEYCLOAK_IMPORT:-}" && -f "${KEYCLOAK_IMPORT}" ]]; then
  echo "Will import realm from ${KEYCLOAK_IMPORT}" >&2
  IMPORT_ARG="-Dkeycloak.import=${KEYCLOAK_IMPORT}"
fi

exec ${KEYCLOAK_HOME}/bin/standalone.sh -b 0.0.0.0 ${IMPORT_ARG} "$@"

