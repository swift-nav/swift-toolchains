#!/bin/bash

OUT=output/opt/llvm-obfuscator/sysroot

rm -rf "$OUT"
mkdir -p "$OUT"

SYSROOT_DIRS=(
  "/usr/arm-linux-gnueabihf/include"
  "/usr/arm-linux-gnueabi/libhf"
  "/usr/arm-linux-gnueabihf/include/c++/4.8.5"
  "/usr/lib/gcc-cross/arm-linux-gnueabihf/4.8"
  "/usr/arm-linux-gnueabihf/include/c++/4.8.5/arm-linux-gnueabihf"
)

for SYSROOT_DIR in ${SYSROOT_DIRS[@]}; do
  mkdir -p "${OUT}/${SYSROOT_DIR}"
  rsync -azv "${SYSROOT_DIR}/" "${OUT}/${SYSROOT_DIR}/"
done
