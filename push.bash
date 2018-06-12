#!/usr/bin/env bash

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

DOCKER_NAMETAG=$(cat docker_nametag)

if [[ -n "${DOCKER_USER:-}" ]] && [[ -n "${DOCKER_PASS:-}" ]]; then
  echo "$DOCKER_PASS" | docker login --username="$DOCKER_USER" --password-stdin
  docker push "$DOCKER_NAMETAG"
  docker push "$DOCKER_NAMETAG-vanilla"
  docker push "$DOCKER_NAMETAG-obfuscator"
else
  echo "WARNING: not pushing new image to Docker Hub..." >&2
fi
