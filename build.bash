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

set -x
set -e

mkdir -p build
mkdir -p output/opt

MAKE_PACKAGES=
VERBOSE=

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
  esac
done

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

PATCH_COMMAND="git apply /patches/*.patch"

docker run -i -t --rm \
    -v $PWD/build:/work/build \
    -v $PWD/output/opt:/opt \
    -v $PWD/patches:/patches \
    "$DOCKER_NAMETAG" \
    /bin/bash -c "cd /work/obfuscator-llvm \
                  && $PATCH_COMMAND \
                  && cd /work/build \
                  && $CMAKE_COMMAND \
                  && ninja $VERBOSE \
                  && ninja $VERBOSE install"

./stage_sysroot.bash
