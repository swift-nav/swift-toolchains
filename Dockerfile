# Copyright (C) 2017 Swift Navigation Inc.
# Contact: Swift Navigation <dev@swiftnav.com>
#
# This source is subject to the license found in the file 'LICENSE' which must
# be be distributed together with this source. All other rights reserved.
#
# THIS CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND,
# EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.

FROM ubuntu:16.04

RUN mkdir /work
WORKDIR /work

RUN    apt-get update \
    && apt-get install -y build-essential \
                          bison \
                          flex \
                          cmake \
                          ninja-build \
                          llvm-4.0 \
                          llvm-4.0-dev \
                          clang-4.0 \
                          git \
                          g++-4.8-arm-linux-gnueabihf \
                          gcc-4.8-arm-linux-gnueabihf \
                          gcc-4.8-multilib-arm-linux-gnueabihf \
                          binutils-arm-linux-gnueabihf \
                          libgcc1-armhf-cross \
                          libsfgcc1-armhf-cross \
                          libstdc++6-armhf-cross \
                          binutils-dev \
                          binutils-multiarch-dev \
                          python

RUN git clone --depth=1 --single-branch -b llvm-4.0 https://github.com/obfuscator-llvm/obfuscator.git obfuscator-llvm

COPY cpp_wrapper.py /bin
RUN chmod +x /bin/cpp_wrapper.py

# EOF
