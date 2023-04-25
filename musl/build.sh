#!/usr/bin/env bash

git clone --depth 1 https://github.com/richfelker/musl-cross-make.git /tmp/musl
cp config.mak /tmp/musl
export CFLAGS="-fPIC -g1 $CFLAGS"
export TARGET=arm-linux-musleabihf
make -C /tmp/musl -j4
make -C /tmp/musl install
tar -C "/tmp/musl" -czf arm-linux-musleabihf.tar.gz output/
