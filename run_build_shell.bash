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

mkdir -p build
mkdir -p output/opt

docker run -i -t --rm \
    -v $PWD/example:/work/example \
    -v $PWD/build:/work/build \
    -v $PWD/output/opt:/opt \
    -v $PWD/bin:/wrapper-bin \
    -v $PWD/patches:/patches \
    arm-llvm-obf:base \
    /bin/bash -c "export PATH=/opt/llvm-obfuscator/bin:/wrapper-bin:\$PATH; exec /bin/bash"
