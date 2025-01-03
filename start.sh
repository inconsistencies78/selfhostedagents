#!/bin/bash

set -e

if [ -z "$AZP_URL" ]; then
  echo "Error: AZP_URL is not set"
  exit 1
fi

if [ -z "$AZP_TOKEN" ]; then
  echo "Error: AZP_TOKEN is not set"
  exit 1
fi

if [ -z "$AZP_POOL" ]; then
  AZP_POOL=Default
fi

echo "1. Configuring Azure DevOps agent..."
./config.sh --unattended --url "$AZP_URL" --auth pat --token "$AZP_TOKEN" --pool "$AZP_POOL" --acceptTeeEula

echo "2. Running agent..."
exec ./run.sh