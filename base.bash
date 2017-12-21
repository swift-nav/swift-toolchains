#!/bin/bash

# Copyright (C) 2017 Swift Navigation Inc.
# Contact: Swift Navigation <dev@swiftnav.com>
#
# This source is subject to the license found in the file 'LICENSE' which must
# be be distributed together with this source. All other rights reserved.
#
# THIS CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND,
# EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.

set -euo pipefail
IFS=$'\n\t'

[[ -z "${DEBUG:-}" ]] || set -x

[[ -n "${DOCKER_USER:-}" ]] || {
  echo "DOCKER_USER: must not be empty"
  exit 1
}

[[ -n "${DOCKER_PASS:-}" ]] || {
  echo "DOCKER_PASS: must not be empty"
  exit 1
}

DOCKER_NAMETAG=$(cat docker_nametag)

query_build_pushed() {

  local repo_tag=$1; shift

  repo_tag=${repo_tag##*:}

  TOKEN=$(curl -s -H "Content-Type: application/json" \
    -X POST -d '{"username": "'"${DOCKER_USER}"'", "password": "'"${DOCKER_PASS}"'"}' \
    https://hub.docker.com/v2/users/login/ | jq -r .token)

  ORG=swiftnav
  REPO=arm-llvm-obf

  curl -s -H "Authorization: JWT ${TOKEN}" \
    https://hub.docker.com/v2/repositories/${ORG}/${REPO}/tags/?page_size=100 \
    | jq '.results | .[] | .name' \
    | grep "$repo_tag"
}

if [[ -n "$(query_build_pushed "$DOCKER_NAMETAG")" ]]; then
  echo "Build already pushed, exiting..."
  exit 0
fi

docker build \
  --force-rm --no-cache \
  -f Dockerfile -t "$DOCKER_NAMETAG" .

echo "$DOCKER_PASS" | docker login --username="$DOCKER_USER" --password-stdin
docker push "$DOCKER_NAMETAG"
