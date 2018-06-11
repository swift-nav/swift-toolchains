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

while [[ $# -gt 0 ]]; do
  case $1 in
  --variant=vanilla)   VARIANT="vanilla";    shift ;;
  --variant=obfuscator)VARIANT="obfuscator"; shift ;;
  *)                                         shift ;;
  esac
done

if [[ -z "${VARIANT:-}" ]]; then
  echo "Error: must a variant --variant=<vanilla|obfuscator>"
  exit 1
fi

DOCKER_NAMETAG=$(cat docker_nametag)
BR2_TOOLCHAIN_LD_LIBRARY_PATH=/toolchain/x86/x86_64-buildroot-linux-gnu/lib64

mkdir -p output/opt

docker run -i -t --rm \
    -v "$PWD/example:/work/example" \
    -v "$PWD/output/opt:/opt" \
    -v "$PWD/bin:/wrapper-bin" \
    -v "$PWD/patches:/patches" \
    -v "$PWD:/this_dir" \
    -v $VARIANT-llvm:/work/$VARIANT-llvm \
    -v $VARIANT-llvm-build:/work/build \
    "$DOCKER_NAMETAG-$VARIANT" \
    /bin/bash -c "export PATH=/opt/llvm-$VARIANT/bin:/opt/llvm-$VARIANT/wrappers/bin:\$PATH; \
                  cp -v /this_dir/cpp_wrapper.c /work/cpp_wrapper.c \
                  && gcc -std=c99 -O3 -Wall /work/cpp_wrapper.c -o /bin/cpp_wrapper; \
                  export BR2_TOOLCHAIN_PATH=/toolchain/arm; \
                  export BR2_TOOLCHAIN_LD_LIBRARY_PATH=$BR2_TOOLCHAIN_LD_LIBRARY_PATH; \
                  exec /bin/bash"
