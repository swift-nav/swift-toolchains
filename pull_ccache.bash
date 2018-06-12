#!/usr/bin/env bash

# Copyright (C) 2018 Swift Navigation Inc.
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

DOCKER_NAMETAG=$(cat docker_nametag)

while [[ $# -gt 0 ]]; do
  case $1 in

  --arch=x86)           ARCH="X86";           shift ;;
  --arch=arm)           ARCH="ARM";           shift ;;
  --arch=arm,x86)       ARCH="ARM\\;X86";     shift ;;
  --arch=x86,arm)       ARCH="ARM\\;X86";     shift ;;

  --variant=vanilla)    VARIANT="vanilla";    shift ;;
  --variant=obfuscator) VARIANT="obfuscator"; shift ;;

  *)                                          shift ;;
  esac
done

if [[ -z "${ARCH:-}" ]]; then
  echo "Error: must specify --arch=<arm|x86|arm,x86|x86,arm>"
  exit 1
fi

if [[ -z "${VARIANT:-}" ]]; then
  echo "Error: must a variant to --variant=<vanilla|obfuscator>"
  exit 1
fi

BUILD_VERSION="$(./most_recent_tag.bash)"
ARCH="${ARCH//\\;/-}"

CCACHE_ARCHIVE="ccache-${VARIANT}-${ARCH}-${BUILD_VERSION}.tbz2"

./s3_download.bash "${CCACHE_ARCHIVE}"

docker run --rm \
    -v "$PWD:/this_dir" \
    -v $VARIANT-llvm-ccache:/work/ccache \
    "$DOCKER_NAMETAG-$VARIANT" \
    /bin/bash -c "tar -xjf /this_dir/${CCACHE_ARCHIVE} -C /work/ccache ."
