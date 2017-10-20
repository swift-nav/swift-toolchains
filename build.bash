#!/bin/bash

set -x
set -e

mkdir -p build
mkdir -p "build-x86"
mkdir -p output/opt

MAKE_PACKAGES=
VERBOSE=

while [[ $# -gt 0 ]]; do
  case $1 in
    --make-packages)
      echo "*** Making packages ***"
      MAKE_PACKAGES=y
      shift
    ;;
    --verbose)
      VERBOSE="-v"
      shift
    ;;
  esac
done

CMAKE_COMMAND="\
    cmake -G Ninja \
        /work/obfuscator-llvm \
        -DCMAKE_INSTALL_PREFIX=/opt/llvm-obfuscator \
        -DLLVM_TARGETS_TO_BUILD=ARM\;X86 \
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
    arm-llvm-obf:base \
    /bin/bash -c "cd /work/obfuscator-llvm \
                  && $PATCH_COMMAND \
                  && cd /work/build \
                  && $CMAKE_COMMAND \
                  && ninja $VERBOSE \
                  && ninja $VERBOSE install"

if [[ -n "$MAKE_PACKAGES" ]]; then

  ./stage_sysroot.bash
  tar -C output -cJf "llvm-obfuscator-arm-x86.txz" .
fi
