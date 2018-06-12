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

  --arch=x86)           ARCH="X86";           shift ;;
  --arch=arm)           ARCH="ARM";           shift ;;
  --arch=arm,x86)       ARCH="ARM\\;X86";     shift ;;
  --arch=x86,arm)       ARCH="ARM\\;X86";     shift ;;

  --variant=vanilla)    VARIANT="vanilla";    shift ;;
  --variant=obfuscator) VARIANT="obfuscator"; shift ;;

  --verbose)            VERBOSE="-v";         shift ;;
  --no-tty)             NO_TTY=--no-tty;      shift ;;

  *)                                          shift ;;
  esac
done

if [[ -z "${ARCH:-}" ]]; then
  echo "Error: must specify --arch=<arm|x86|arm,x86|x86,arm>"
  exit 1
fi

if [[ -z "${VARIANT:-}" ]]; then
  echo "Error: must a variant to build --variant=<vanilla|obfuscator>"
  exit 1
fi

CXX_FLAGS="-L/toolchain/x86/x86_64-buildroot-linux-gnu/sysroot/lib \
  -L/toolchain/x86/x86_64-buildroot-linux-gnu/sysroot/usr/lib \
  -I/toolchain/x86/lib/gcc/x86_64-buildroot-linux-gnu/6.4.0/plugin/include"

if [[ "$VARIANT" == "obfuscator" ]]; then
  LLVM_REPO="https://github.com/obfuscator-llvm/obfuscator.git"
  LLVM_BRANCH="llvm-4.0"
  CLANG_REPO=""
  CLANG_TOOLS_EXTRA_REPO=""
  CPP_WRAPPER_DEFINE="-DCMAKE_CXX_COMPILER=/bin/cpp_wrapper"
  PATCH_COMMAND="{ git apply /patches/*.patch || : ; }"
  COMPILE_CPP_WRAPPER="cp -v /this_dir/cpp_wrapper.c /work/cpp_wrapper.c \
                       && gcc -std=c99 -O3 -Wall /work/cpp_wrapper.c -o /bin/cpp_wrapper"
else
  LLVM_REPO="https://github.com/llvm-mirror/llvm.git"
  CLANG_REPO="https://github.com/llvm-mirror/clang.git"
  CLANG_TOOLS_EXTRA_REPO="https://github.com/llvm-mirror/clang-tools-extra.git"
  LLVM_BRANCH="release_60"
  CPP_WRAPPER_DEFINE="-DCMAKE_CXX_COMPILER=/toolchain/x86/bin/x86_64-linux-g++"
  PATCH_COMMAND="true"
  COMPILE_CPP_WRAPPER="true"
  CXX_FLAGS+=" -I/work/$VARIANT-llvm/tools/clang/include"
  CXX_FLAGS+=" -I/work/build/tools/clang/include"
fi

CMAKE_COMMAND="\
    cmake -G Ninja \
        /work/$VARIANT-llvm \
        -DCMAKE_INSTALL_PREFIX=/opt/llvm-$VARIANT \
        -DLLVM_TARGETS_TO_BUILD=$ARCH \
        -DCMAKE_CXX_FLAGS='-DENDIAN_LITTLE=1 $CXX_FLAGS' \
        -DLLVM_CCACHE_BUILD=ON \
        $CPP_WRAPPER_DEFINE \
        -DCMAKE_C_COMPILER=/toolchain/x86/bin/x86_64-linux-gcc \
        -DCMAKE_BUILD_TYPE=Release \
        -DLLVM_BINUTILS_INCDIR=/usr/include \
        -DLLVM_ENABLE_TERMINFO=0 \
        -DLLVM_INCLUDE_TESTS=OFF"

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
    -v $VARIANT-llvm-ccache:/work/ccache \
    -v $VARIANT-llvm:/work/$VARIANT-llvm \
    -v $VARIANT-llvm-build:/work/build \
    -e VARIANT=$VARIANT -e ARCH=$ARCH \
    -e VERBOSE=$VERBOSE -e NO_TTY=$NO_TTY \
    -e CPP_WRAPPER_DEFINE=$CPP_WRAPPER_DEFINE \
    -e CMAKE_COMMAND="$CMAKE_COMMAND" \
    -e LLVM_REPO=$LLVM_REPO \
    -e LLVM_BRANCH=$LLVM_BRANCH \
    -e CLANG_REPO=$CLANG_REPO \
    -e CLANG_TOOLS_EXTRA_REPO=$CLANG_TOOLS_EXTRA_REPO \
    -e PATCH_COMMAND=$PATCH_COMMAND \
    -e COMPILE_CPP_WRAPPER=$COMPILE_CPP_WRAPPER \
    -e CCACHE_DIR=/work/ccache \
    "$DOCKER_NAMETAG-$VARIANT" \
    /bin/bash -c "/this_dir/do_clang_build.bash"

./stage_sysroot.bash $NO_TTY "--variant=$VARIANT"
