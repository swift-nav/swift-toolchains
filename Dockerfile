# Copyright (C) 2017-2018 Swift Navigation Inc.
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

ENV TOOLCHAIN_URL_BASE https://toolchains.bootlin.com/downloads/releases/toolchains

ENV TOOLCHAIN_X86_URL ${TOOLCHAIN_URL_BASE}/x86-64-core-i7/tarballs/x86-64-core-i7--glibc--stable-2018.02-2.tar.bz2
ENV TOOLCHAIN_ARM_URL ${TOOLCHAIN_URL_BASE}/armv7-eabihf/tarballs/armv7-eabihf--glibc--stable-2018.02-2.tar.bz2

RUN    apt-get update \
    && apt-get install -y wget \
    && wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - \
    && echo "deb http://apt.llvm.org/xenial/ llvm-toolchain-xenial-4.0 main" \
          >/etc/apt/sources.list.d/llvm40.list \
    && apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y libcurl4-openssl-dev \
                          build-essential \
                          bison \
                          flex \
                          ninja-build \
                          llvm-4.0 \
                          llvm-4.0-dev \
                          clang-4.0 \
                          git \
                          m4 \
                          gperf \
                          gawk \
                          ncurses-dev \
                          texinfo \
                          help2man \
                          binutils-dev \
                          libpthread-stubs0-dev \
                          libtinfo-dev \
                          python \
                          python-dev \
                          binutils-multiarch-dev \
                          g++-4.8-arm-linux-gnueabihf \
                          gcc-4.8-arm-linux-gnueabihf \
                          gcc-4.8-multilib-arm-linux-gnueabihf \
                          binutils-arm-linux-gnueabihf \
                          libgcc1-armhf-cross \
                          libsfgcc1-armhf-cross \
                          libstdc++6-armhf-cross \
    && wget -O /tmp/bootlin-toolchain-x86.tbz2 ${TOOLCHAIN_X86_URL} \
    && wget -O /tmp/bootlin-toolchain-arm.tbz2 ${TOOLCHAIN_ARM_URL} \
    && mkdir -p /toolchain/x86 /toolchain/arm \
    && tar -C /toolchain/x86 --strip-components=1 -xvjf \
        /tmp/bootlin-toolchain-x86.tbz2 \
    && tar -C /toolchain/arm --strip-components=1 -xvjf \
        /tmp/bootlin-toolchain-arm.tbz2 \
    && rm /tmp/bootlin-toolchain-x86.tbz2 /tmp/bootlin-toolchain-arm.tbz2 \
    && mkdir -p cmake-build && cd cmake-build \
    && wget https://cmake.org/files/v3.10/cmake-3.10.1.tar.gz \
    && tar -xzf cmake-3.10.1.tar.gz \
    && cd cmake-3.10.1 \
    && ./configure \
    && make -j4 \
    && make install \
    && cd .. && rm -rf cmake-* \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# EOF
