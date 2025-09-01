#!/bin/bash
set -e

# decrypt-activation-key.sh
# Usage: source this file and call decrypt_activation_key or decrypt_and_get_license_edition
# It reads ROR_ACTIVATION_KEY env and attempts to return the decrypted/plain activation key.
# Supported formats:
# - plain text: returned as-is
# - base64 encoded: decoded automatically if decoding succeeds
# - openssl prefixed: openssl:<cipher>:<base64_ciphertext>
#   requires ROR_KEY_PASSPHRASE env to be set

decrypt_activation_key() {
  local key="${ROR_ACTIVATION_KEY:-}"
  if [ -z "$key" ]; then
    return 1
  fi

  # openssl: format: openssl:<cipher>:<base64_ciphertext>
  if [[ "$key" == openssl:* ]]; then
    # split into parts
    IFS=':' read -r prefix cipher b64 <<< "$key"
    if [ -z "$cipher" ] || [ -z "$b64" ]; then
      echo "Malformed openssl activation key (expected openssl:<cipher>:<base64>)" >&2
      return 2
    fi
    if [ -z "${ROR_KEY_PASSPHRASE:-}" ]; then
      echo "ROR_KEY_PASSPHRASE not set; cannot decrypt openssl activation key" >&2
      return 3
    fi
    # Decode base64 then decrypt
    echo "$b64" | base64 --decode 2>/dev/null | openssl enc -d "-$cipher" -pass pass:"$ROR_KEY_PASSPHRASE" 2>/dev/null
    return $?
  fi

  # Try base64 detection: only base64 chars and reasonable length
  if echo "$key" | grep -qE '^[A-Za-z0-9+/=]+$' && [ $(( ${#key} % 4 )) -eq 0 ]; then
    # attempt decode
    dec=$(echo "$key" | base64 --decode 2>/dev/null || true)
    if [ -n "$dec" ]; then
      # if decoded content looks printable, return it
      if echo "$dec" | grep -qP '^[\x20-\x7E\t\n\r]+$'; then
        printf "%s" "$dec"
        return 0
      fi
    fi
  fi

  # fallback: return as-is
  printf "%s" "$key"
  return 0
}

# base64url -> base64
_b64url_to_b64() {
  local s="$1"
  # replace URL-safe chars and add padding
  s=$(printf '%s' "$s" | tr '_-' '/+')
  local mod=$(( ${#s} % 4 ))
  if [ $mod -eq 2 ]; then s="$s""=="; fi
  if [ $mod -eq 3 ]; then s="$s""="; fi
  printf '%s' "$s"
}

# Extract license.edition from a JWT token string
extract_license_edition_from_jwt() {
  local jwt="$1"
  if [ -z "$jwt" ]; then
    return 1
  fi
  # ensure token has 3 parts
  if ! echo "$jwt" | grep -qE '^[^\.]+\.[^\.]+\.[^\.]+$'; then
    return 2
  fi
  IFS='.' read -r header payload signature <<< "$jwt"
  # convert payload from base64url to base64 and decode
  b64_payload=$(_b64url_to_b64 "$payload")
  decoded=$(printf '%s' "$b64_payload" | base64 --decode 2>/dev/null || true)
  if [ -z "$decoded" ]; then
    return 3
  fi

  # Try to parse JSON and extract license.edition using node if available
  if [ -x "/usr/share/kibana/node/bin/node" ]; then
    edition=$(printf '%s' "$decoded" | /usr/share/kibana/node/bin/node -e 'let s="";const fs=require("fs");s=fs.readFileSync(0,"utf8");try{const j=JSON.parse(s);console.log((j.license&&j.license.edition)?j.license.edition:"") }catch(e){process.exit(2)}') || true
    printf '%s' "$edition"
    return 0
  fi

  # Fallback: crude extraction using grep/sed (best-effort)
  edition=$(printf '%s' "$decoded" | tr -d '\n' | sed -n 's/.*"license"[[:space:]]*:[[:space:]]*{[^}]*"edition"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' || true)
  printf '%s' "$edition"
  return 0
}

# High-level helper: decrypt the activation key and, if it's a JWT, print license.edition
decrypt_and_get_license_edition() {
  local decrypted
  if ! decrypted=$(decrypt_activation_key); then
    return 1
  fi
  # If looks like JWT, try to extract edition
  if echo "$decrypted" | grep -qE '^[^\.]+\.[^\.]+\.[^\.]+$'; then
    extract_license_edition_from_jwt "$decrypted"
    return $?
  fi
  # not a JWT: no edition
  return 2
}
