#!/usr/bin/env sh
# Extract 'license.edition' from a JWT (prints edition)
# Usage: extract_license_edition.sh <jwt>
set -eu
[ "$#" -ge 1 ] || exit 1
jwt="$1"
[ -n "$jwt" ] || exit 1

# Use python3 for robust JSON parsing; fail if not present
if command -v python3 >/dev/null 2>&1; then
  # run python and capture both stdout/stderr and exit code using a temp file
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
    exit 2
  fi
  edition=$(printf '%s' "$output" | tr -d '\r' | sed -n '1p')
  if [ -z "$edition" ]; then
    exit 2
  fi
  printf '%s' "$edition"
  exit 0
fi

# python3 not available: fail with message
printf '%s\n' "ERROR: python3 is required but was not found in PATH." >&2
exit 2
