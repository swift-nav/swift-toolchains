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

D=$( (cd "$(dirname "$0")" || exit 1 >/dev/null; pwd -P) )

[[ -n "${DOCKER_USER:-}" ]] || {
  echo "DOCKER_USER: must not be empty"
  exit 1
}

[[ -n "${DOCKER_PASS:-}" ]] || {
  echo "DOCKER_PASS: must not be empty"
  exit 1
}

DOCKER_NAMETAG=$(cat docker_nametag)

docker build \
  --force-rm --no-cache \
  -f Dockerfile -t $DOCKER_NAMETAG .

echo "$DOCKER_PASS" | docker login --username="$DOCKER_USER" --password-stdin
docker push $DOCKER_NAMETAG
