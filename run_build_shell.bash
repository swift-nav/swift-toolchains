#!/bin/bash

mkdir -p build
mkdir -p output/opt

docker run -i -t --rm \
    -v $PWD/example:/work/example \
    -v $PWD/build:/work/build \
    -v $PWD/output/opt:/opt \
    -v $PWD/bin:/wrapper-bin \
    arm-llvm-obf:base \
    /bin/bash -c "export PATH=/opt/llvm-obfuscator/bin:/wrapper-bin:\$PATH; exec /bin/bash"
