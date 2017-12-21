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

DOCKER_NAMETAG=$(cat docker_nametag)

mkdir -p output/opt

VERBOSE=
NO_TTY=

while [[ $# -gt 0 ]]; do
  case $1 in
  --verbose)
  VERBOSE="-v"
  shift
  ;;
  --arch=x86)
  ARCH="X86"
  shift
  ;;
  --arch=arm)
  ARCH="ARM"
  shift
  ;;
  --no-tty)
  NO_TTY=--no-tty
  shift
  ;;
  esac
done

if [[ -z "${ARCH:-}" ]]; then
  echo "Error: must specify --arch=<arm|x86>"
  exit 1
fi

set -x

CMAKE_COMMAND="\
    cmake -G Ninja \
        /work/obfuscator-llvm \
        -DCMAKE_INSTALL_PREFIX=/opt/llvm-obfuscator \
        -DLLVM_TARGETS_TO_BUILD=$ARCH \
        -DCMAKE_CXX_FLAGS='-DENDIAN_LITTLE=1' \
        -DCMAKE_C_COMPILER=/usr/bin/gcc \
        -DCMAKE_CXX_COMPILER=/bin/cpp_wrapper.py \
        -DCMAKE_BUILD_TYPE=Release \
        -DLLVM_BINUTILS_INCDIR=/usr/include \
        -DLLVM_INCLUDE_TESTS=OFF"

PATCH_COMMAND="{ git apply /patches/*.patch || : ; }"

if [[ -z "$NO_TTY" ]]; then
  INTERACTIVE=("-i" "-t")
else
  INTERACTIVE=()
fi

# shellcheck disable=SC2068
docker run ${INTERACTIVE[@]:-} --rm \
    -v "$PWD/output/opt:/opt" \
    -v "$PWD/patches:/patches" \
    -v obfuscator-llvm:/work/obfuscator-llvm \
    -v obfuscator-llvm-build:/work/build \
    "$DOCKER_NAMETAG" \
    /bin/bash -c "if [ ! -d /work/obfuscator-llvm/.git ]; then \
                      git clone --depth=1 --single-branch -b llvm-4.0 \
                        https://github.com/obfuscator-llvm/obfuscator.git \
                        obfuscator-llvm;
                  else \
                    (cd /work/obfuscator-llvm && git pull); \
                  fi \
                  && cd /work/obfuscator-llvm \
                  && $PATCH_COMMAND \
                  && cd /work/build \
                  && $CMAKE_COMMAND \
                  && ninja $VERBOSE \
                  && ninja $VERBOSE install"

./stage_sysroot.bash $NO_TTY
