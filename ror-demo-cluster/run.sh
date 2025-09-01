#!/bin/bash -e

export LC_ALL=C

# remove any leftover debug file from earlier runs
rm -f ./ror-extract-debug.log 2>/dev/null || true

if ! docker version &>/dev/null; then
  echo "No Docker found. Docker is required to run this Sandbox. See https://docs.docker.com/engine/install/"
  exit 1
fi

if ! docker compose version &>/dev/null; then
  echo "No docker compose found. It seems you have to upgrade your Docker installation. See https://docs.docker.com/engine/install/"
  exit 2
fi

# validate base compose file
if ! docker compose -f docker-compose.yml config > /dev/null; then
  echo "Cannot validate base docker-compose.yml."
  exit 3
fi

echo -e "

  _____                _  ____        _       _____  ______  _____ _______
 |  __ \              | |/ __ \      | |     |  __ \|  ____|/ ____|__   __|
 | |__) |___  __ _  __| | |  | |_ __ | |_   _| |__) | |__  | (___    | |
 |  _  // _ \/ _| |/ _| | |  | | '_ \| | | | |  _  /|  __|  \___ \   | |
 | | \ \  __/ (_| | (_| | |__| | | | | | |_| | | \ \| |____ ____) |  | |
 |_|  \_\___|\__,_|\__,_|\____/|_| |_|_|\__, |_|  \_\______|_____/   |_|
                                         __/ |
"

./../utils/collect-info-about-ror-es-kbn.sh || true

echo "Starting Elasticsearch and Kibana with installed ROR plugins ..."

# If ROR_ACTIVATION_KEY is set and ROR_LICENSE_EDITION is not, try to auto-extract license edition
_decode_base64() {
  # read from stdin, try GNU and BSD base64 flags
  if command -v base64 >/dev/null 2>&1; then
    base64 --decode 2>/dev/null || base64 -D 2>/dev/null || return 1
  else
    return 1
  fi
}

_extract_license_edition_from_jwt() {
  local jwt="$1"
  [ -z "$jwt" ] && return 1

  # get payload (middle part)
  local tail payload
  tail=${jwt#*.}
  payload=${tail%%.*}
  [ -z "$payload" ] && return 1

  # Prefer python3 for safe JSON parsing if available
  if command -v python3 >/dev/null 2>&1; then
    edition=$(ROR_JWT="$jwt" python3 - <<'PY' || true
import os,base64,json,sys
s=os.environ.get('ROR_JWT','')
parts=s.split('.')
if len(parts) < 2:
    sys.exit(1)
p=parts[1]
rem=len(p) % 4
if rem:
    p += '=' * (4 - rem)
decoded=base64.urlsafe_b64decode(p.encode('utf-8'))
try:
    j=json.loads(decoded.decode('utf-8'))
    print(j.get('license',{}).get('edition',''))
except Exception:
    sys.exit(2)
PY
)
    if [ -n "$edition" ]; then
      printf '%s' "$edition"
      return 0
    fi
    return 3
  fi

  # Fallback: decode payload and extract via perl/sed
  local b64 decoded edition
  b64=$(printf '%s' "$payload" | tr '_-' '/+')
  local mod=$(( ${#b64} % 4 ))
  if [ $mod -ne 0 ]; then
    local pad=$((4 - mod))
    b64="$b64"$(printf '=%.0s' $(seq 1 $pad))
  fi
  decoded=$(printf '%s' "$b64" | _decode_base64 2>/dev/null || true)
  [ -z "$decoded" ] && return 2

  if command -v perl >/dev/null 2>&1; then
    edition=$(printf '%s' "$decoded" | perl -0777 -ne 'print $1 if /"license"\s*:\s*\{.*?"edition"\s*:\s*"([^\"]+)"/s' || true)
  else
    edition=$(printf '%s' "$decoded" | tr -d '\n' | sed -n 's/.*"license"[[:space:]]*:[[:space:]]*{[^}]*"edition"[[:space:]]*:[[:space:]]*"\([^\"]*\)".*/\1/p' || true)
  fi

  if [ -n "$edition" ]; then
    printf '%s' "$edition"
    return 0
  fi
  return 3
}

if [ -n "${ROR_ACTIVATION_KEY:-}" ] && [ -z "${ROR_LICENSE_EDITION:-}" ]; then
  echo "ROR_ACTIVATION_KEY detected, attempting to auto-detect ROR_LICENSE_EDITION..."
  candidate="${ROR_ACTIVATION_KEY}"

  # If candidate looks like raw JSON (decoded activation key), parse it directly
  if printf '%s' "$candidate" | grep -qE '^\s*\{'; then
    if command -v python3 >/dev/null 2>&1; then
      edition=$(printf '%s' "$candidate" | python3 - <<'PY' 2>/dev/null || true
import sys,json
s=sys.stdin.read()
try:
    j=json.loads(s)
    print(j.get('license',{}).get('edition',''))
except Exception:
    sys.exit(1)
PY
)
      if [ -n "$edition" ]; then
        export ROR_LICENSE_EDITION="$edition"
        echo "Auto-detected (JSON) ROR_LICENSE_EDITION=$ROR_LICENSE_EDITION"
      fi
    fi
  fi

  # If still not set, try base64 decode and JWT extraction
  if [ -z "${ROR_LICENSE_EDITION:-}" ]; then
    # If looks like base64, try to decode
    if echo "$candidate" | grep -qE '^[A-Za-z0-9+/=]+$' && [ $(( ${#candidate} % 4 )) -eq 0 ]; then
      dec=$(printf '%s' "$candidate" | _decode_base64 || true)
      if [ -n "$dec" ]; then
        candidate="$dec"
      fi
    fi

    # If encrypted with openssl:<cipher>:<base64>, try to decrypt (helper script must exist)
    if echo "$candidate" | grep -qE '^openssl:' && [ -f ./images/kbn/decrypt-activation-key.sh ]; then
      # shellcheck disable=SC1090
      . ./images/kbn/decrypt-activation-key.sh
      if decrypted=$(decrypt_activation_key 2>/dev/null || true); then
        if [ -n "$decrypted" ]; then
          candidate="$decrypted"
        fi
      fi
    fi

    # If candidate is a JWT, extract
    if echo "$candidate" | grep -qE '^[^\.]+\.[^\.]+\.[^\.]+$'; then
      if edition=$(_extract_license_edition_from_jwt "$candidate"); then
        export ROR_LICENSE_EDITION="$edition"
        echo "Auto-detected ROR_LICENSE_EDITION=$ROR_LICENSE_EDITION"
      fi
    fi
  fi
fi

# Build compose file list; include Keycloak profile only when ROR_ACTIVATION_KEY is set
COMPOSE_ARGS=("-f" "docker-compose.yml")
PROFILE_ARGS=()
if [[ "${ROR_LICENSE_EDITION:-}" == "kbn_ent" ]]; then
  COMPOSE_ARGS+=("-f" "docker-compose.enterprise.yml")
  PROFILE_ARGS+=("--profile" "enterprise")
  echo "Activating 'enterprise' profile for compose"
fi

# Run docker compose with selected files and profiles
docker compose "${PROFILE_ARGS[@]}" "${COMPOSE_ARGS[@]}" up -d --build --wait --remove-orphans --force-recreate

docker compose logs -f > ror-cluster.log 2>&1 &

echo -e "
***********************************************************************
***                                                                 ***
***          TIME TO PLAY!!!                                        ***
***                                                                 ***
***********************************************************************
"


if [[ "${ROR_LICENSE_EDITION:-}" == "kbn_ent" ]]; then
  echo -e "You can access ROR KBN here: https://localhost:15601 (login via 'Keycloak' button; users: 'timelord:timelord', 'user1:user1').\nKeycloak admin console: http://localhost:8080/auth (admin:admin)"
else
  echo -e "You can access ROR KBN here: https://localhost:15601"
fi