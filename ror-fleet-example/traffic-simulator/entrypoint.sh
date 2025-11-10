#!/bin/bash -x

make_request() {
  local url=$1
  curl -s -o /dev/null -w "%{http_code}" "$url"
}

while true; do 
  RAND=$(( RANDOM % 10 + 1 ))

  if [ "$RAND" -le 1 ]; then
    URL="http://service1:3000/error"
  else
    URL="http://service1:3000"
  fi

  make_request "$URL"

  sleep 10000
done
