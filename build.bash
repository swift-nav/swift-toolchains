#!/bin/bash

mkdir -p build
mkdir -p output/opt

CMAKE_COMMAND="\
    cmake -G Ninja \
        /work/obfuscator-llvm \
        -DCMAKE_CROSSCOMPILING=True \
        -DCMAKE_INSTALL_PREFIX=/opt/llvm-obfuscator \
        -DLLVM_TABLEGEN=/usr/bin/llvm-tblgen-4.0 \
        -DCLANG_TABLEGEN=/usr/bin/clang-tblgen-4.0 \
        -DLLVM_DEFAULT_TARGET_TRIPLE=arm-linux-gnueabihf \
        -DLLVM_TARGET_ARCH=ARM \
        -DLLVM_TARGETS_TO_BUILD=ARM \
        -DCMAKE_CXX_FLAGS='-march=armv7-a -mcpu=cortex-a9 -mfloat-abi=hard -DENDIAN_LITTLE=1' \
        -DCMAKE_C_COMPILER=/usr/bin/arm-linux-gnueabihf-gcc-4.8 \
        -DCMAKE_CXX_COMPILER=/bin/cpp_wrapper.py \
        -DCMAKE_BUILD_TYPE=Release \
        -DLLVM_INCLUDE_TESTS=OFF"

docker run -i -t --rm \
    -v $PWD/build:/work/build \
    -v $PWD/output/opt:/opt \
    arm-llvm-obf:base \
    /bin/bash -c "cd /work/build && $CMAKE_COMMAND && ninja -v && ninja -v install"
