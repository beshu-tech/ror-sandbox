#!/bin/bash

echo "🏃🏿‍♂️‍➡️ build_starter: installing dependencies"
# coolify-helper image uses Alpine
apk update && apk add jq curl

echo "🏃🏿‍♂️‍➡️ build_starter: setting up environment variables"
source set_env_vars.sh

echo "🏃🏿‍♂️‍➡️ build_starter: starting the 🐳 build"
docker compose build
