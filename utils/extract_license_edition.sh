#!/usr/bin/env sh
# Extract 'license.edition' from a JWT (prints edition)
# Usage: extract_license_edition.sh <jwt>
set -eu
[ "$#" -ge 1 ] || { printf '%s\n' "Missing argument: JWT required" >&2; exit 1; }
jwt="$1"

function extractLicense() {
  local tmpf rc output edition
  tmpf=$(mktemp 2>/dev/null || (printf '/tmp/extract_license_edition.XXXXXX' && mktemp -t extract_license_edition))
  JWT="$jwt" python3 - <<'PY' >"$tmpf" 2>&1
import os,base64,json,sys
s=os.environ.get('JWT','')
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
except Exception as e:
    sys.stderr.write(str(e) + "\n")
    sys.exit(2)
PY
  rc=$?
  output=$(cat "$tmpf" 2>/dev/null || true)
  rm -f "$tmpf" 2>/dev/null || true
  if [ "$rc" -ne 0 ]; then
    printf '%s\n' "$output" >&2
    return 2
  fi
  edition=$(printf '%s' "$output" | tr -d '\r' | sed -n '1p')
  if [ -z "$edition" ]; then
    return 2
  fi
  printf '%s' "$edition"
  return 0
}



# Execute the python snippet: prefer local python3, fallback to docker

if command -v python3 >/dev/null 2>&1; then
extractLicense

else
  printf '%s' "$jwt" | docker run --rm -i python:3.12-slim python3 - <<PY
extractLicense
PY
fi