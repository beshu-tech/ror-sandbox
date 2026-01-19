#!/bin/bash -e

echo "=== Service1 Starting ==="
echo "Waiting 10 seconds for APM Server to be fully ready..."
sleep 10

echo "Starting Node.js application..."
exec node /example-app/app.js

