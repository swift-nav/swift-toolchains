#!/bin/bash

set -x

stage_sysroot() {

  OUT=/opt/llvm-obfuscator/sysroot

  rm -rf "$OUT"
  mkdir -p "$OUT"

  SYSROOT_DIRS=(
    "/usr/arm-linux-gnueabihf"
    "/usr/arm-linux-gnueabi"
    "/usr/lib/gcc-cross/arm-linux-gnueabihf/4.8"
  )

  for SYSROOT_DIR in ${SYSROOT_DIRS[@]}; do
    mkdir -p "${OUT}/${SYSROOT_DIR}"
    rsync -azv "${SYSROOT_DIR}/" "${OUT}/${SYSROOT_DIR}/"
  done

  WRAPPERS_BIN=/opt/llvm-obfuscator/wrappers/bin

  mkdir -p $WRAPPERS_BIN
  rsync -asv '--exclude=.*.sw?' /this_dir/bin/ $WRAPPERS_BIN/

  BINTOOLS=(
    /usr/bin/arm-linux-gnueabihf-ar
    /usr/bin/arm-linux-gnueabihf-as
    /usr/bin/arm-linux-gnueabihf-ld
    /usr/bin/arm-linux-gnueabihf-ld.bfd
    /usr/bin/arm-linux-gnueabihf-ld.gold
    /usr/bin/arm-linux-gnueabihf-nm
    /usr/bin/arm-linux-gnueabihf-objcopy
    /usr/bin/arm-linux-gnueabihf-objdump
    /usr/bin/arm-linux-gnueabihf-ranlib
    /usr/bin/arm-linux-gnueabihf-readelf
    /usr/bin/arm-linux-gnueabihf-strip
  )

  mkdir -p "${OUT}/usr/bin/"

  for BINTOOL in ${BINTOOLS[@]}; do
    cp -v ${BINTOOL} "${OUT}/usr/bin/"
  done

  D="${OUT}/usr/lib/x86_64-linux-gnu/"

  mkdir -p "$D"

  for ARMHF in /usr/lib/x86_64-linux-gnu/*armhf*; do
    cp -v "${ARMHF}" "$D/"
  done
}

run() {

  if [[ -n "$DOCKERCEPTION" ]]; then return; fi

  docker run -i -t --rm \
      -v $PWD/example:/work/example \
      -v $PWD/build:/work/build \
      -v $PWD/output/opt:/opt \
      -v $PWD:/this_dir \
      -e DOCKERCEPTION=1 \
      arm-llvm-obf:base \
      /bin/bash -c ". /this_dir/stage_sysroot.bash; stage_sysroot"
}

run