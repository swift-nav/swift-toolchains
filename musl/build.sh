#!/usr/bin/env bash

set -ex

if [ $# -ne 1 ]; then
    echo "usage: $0 target" 2>&1
    exit 1
fi

target=$1

git clone --depth 1 https://github.com/richfelker/musl-cross-make.git /tmp/musl
cp musl/config.mak /tmp/musl
export CFLAGS="-fPIC -g1 $CFLAGS"
export TARGET=$target
make -C /tmp/musl -j4
make -C /tmp/musl install
tar -C /tmp/musl -czf ${target}.tar.gz output/
sha256sum ${target}.tar.gz > ${target}.tar.gz.sha256
