#!/bin/bash

mkdir -p build
mkdir -p output/opt

docker run -i -t --rm \
    -v $PWD/example:/work/example \
    -v $PWD/build:/work/build \
    -v $PWD/output/opt:/opt \
    arm-llvm-obf:base \
    /bin/bash -c "export PATH=/opt/llvm-obfuscator/bin:\$PATH; \
                  make -C example"
