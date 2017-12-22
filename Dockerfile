# Copyright (C) 2017 Swift Navigation Inc.
# Contact: Swift Navigation <dev@swiftnav.com>
#
# This source is subject to the license found in the file 'LICENSE' which must
# be be distributed together with this source. All other rights reserved.
#
# THIS CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND,
# EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.

FROM ubuntu:14.04

RUN mkdir /work
WORKDIR /work

RUN    apt-get update \
    && apt-get install -y wget \
    && wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - \
    && echo "deb http://apt.llvm.org/trusty/ llvm-toolchain-trusty-4.0 main" \
          >/etc/apt/sources.list.d/llvm40.list \
    && apt-get update \
    && apt-get install -y libcurl4-openssl-dev \
                          checkinstall \
                          build-essential \
                          bison \
                          flex \
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
                          python \
    && mkdir -p cmake-build && cd cmake-build \
    && wget https://cmake.org/files/v3.10/cmake-3.10.1.tar.gz \
    && tar -xzf cmake-3.10.1.tar.gz \
    && cd cmake-3.10.1 \
    && ./configure \
    && make -j4 \
    && checkinstall -yD make install \
    && cd .. && rm -rf cmake-* \
    && apt-get -y --force-yes remove checkinstall \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# EOF
