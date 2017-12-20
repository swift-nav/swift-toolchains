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

DOCKER_NAMETAG=swiftnav/arm-llvm-obf:4.0

mkdir -p build
mkdir -p output/opt

NO_TTY=

while [[ $# -gt 0 ]]; do
  case $1 in
  --no-tty)
  NO_TTY=y
  shift
  ;;
  esac
done

if [[ -z "$NO_TTY" ]]; then
  INTERACTIVE="-i -t"
else
  INTERACTIVE=
fi

docker run $INTERACTIVE --rm \
    -v $PWD/example:/work/example \
    -v $PWD/build:/work/build \
    -v $PWD/output/opt:/opt \
    $DOCKER_NAMETAG \
    /bin/bash -c "export PATH=/opt/llvm-obfuscator/bin:/opt/llvm-obfuscator/wrappers/bin:\$PATH; \
                  make -C example"
