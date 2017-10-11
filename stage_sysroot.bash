#!/bin/bash

set -x

stage_sysroot() {

  OUT=/opt/llvm-obfuscator/sysroot

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

  WRAPPERS_BIN=/opt/llvm-obfuscator/wrappers/bin

  mkdir -p $WRAPPERS_BIN
  rsync -asv '--exclude=.*.sw?' /this_dir/bin/ $WRAPPERS_BIN/
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
