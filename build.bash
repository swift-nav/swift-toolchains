#!/usr/bin/env bash

# Copyright (C) 2017-2018 Swift Navigation Inc.
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

  --arch=x86)       ARCH="X86";       shift ;;
  --arch=arm)       ARCH="ARM";       shift ;;
  --arch=arm,x86)   ARCH="ARM\\;X86";   shift ;;
  --arch=x86,arm)   ARCH="X86\\;ARM";   shift ;;

  --verbose)        VERBOSE="-v";     shift ;;
  --no-tty)         NO_TTY=--no-tty;  shift ;;

  *)                                  shift ;;
  esac
done

if [[ -z "${ARCH:-}" ]]; then
  echo "Error: must specify --arch=<arm|x86>"
  exit 1
fi

set -x
#        -DLLVM_BUILD_TOOLS:BOOL=FALSE \

CMAKE_COMMAND="\
    cmake -G Ninja \
        /work/obfuscator-llvm \
        -DCMAKE_INSTALL_PREFIX=/opt/llvm-obfuscator \
        -DLLVM_TARGETS_TO_BUILD=$ARCH \
        -DCMAKE_CXX_FLAGS='-DENDIAN_LITTLE=1 -I/toolchain/x86/lib/gcc/x86_64-buildroot-linux-gnu/6.4.0/plugin/include' \
        -DCMAKE_C_COMPILER=/toolchain/x86/bin/x86_64-linux-gcc \
        -DCMAKE_CXX_COMPILER=/bin/cpp_wrapper \
        -DCMAKE_BUILD_TYPE=Release \
        -DLLVM_BINUTILS_INCDIR=/usr/include \
        -DLLDB_DISABLE_CURSES:BOOL=TRUE \
        -DLLVM_ENABLE_TERMINFO=0 \
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
    -v "$PWD:/this_dir" \
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
                  && cp -v /this_dir/cpp_wrapper.c /work/cpp_wrapper.c \
                  && gcc -std=c99 -O3 -Wall /work/cpp_wrapper.c -o /bin/cpp_wrapper \
                  && cd /work/obfuscator-llvm \
                  && $PATCH_COMMAND \
                  && cd /work/build \
                  && $CMAKE_COMMAND \
                  && ninja $VERBOSE \
                  && ninja $VERBOSE install"

./stage_sysroot.bash $NO_TTY
