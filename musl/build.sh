#!/usr/bin/env bash

set -ex

if [ $# -ne 1 ]; then
    echo "usage: $0 target" 2>&1
    exit 1
fi

target=$1

git clone https://github.com/richfelker/musl-cross-make.git /tmp/musl
# Later commits add a musl 1.1.24 patch with a stray conflict marker (upstream issue #232).
git -C /tmp/musl checkout e5147dde912478dd32ad42a25003e82d4f5733aa
cp musl/config.mak /tmp/musl
export CFLAGS="-fPIC -g1 $CFLAGS"
export TARGET=$target
make -C /tmp/musl -j4
make -C /tmp/musl install
tar -C /tmp/musl -czf ${target}-cross.tar.gz output/
sha256sum ${target}-cross.tar.gz > ${target}-cross.tar.gz.sha256
