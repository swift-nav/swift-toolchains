#!/usr/bin/env bash

# Copyright (C) 2017 Swift Navigation Inc.
# Contact: Swift Navigation <dev@swiftnav.com>
#
# This source is subject to the license found in the file 'LICENSE' which must
# be be distributed together with this source. All other rights reserved.
#
# THIS CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND,
# EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.

## Strict mode
set -euo pipefail
IFS=$'\n\t'

## Debug mode
set -x

if [[ -z "${DOCKERCEPTION:-}" ]]; then

  ## Init vars
  export DOCKER_NAMETAG
  DOCKER_NAMETAG=$(cat docker_nametag)

  export INTERACTIVE
  INTERACTIVE=("-i" "-t")

  while [[ $# -gt 0 ]]; do
    case $1 in
    --no-tty) export INTERACTIVE=();           shift ;;
    --variant=vanilla)   VARIANT="vanilla";    shift ;;
    --variant=obfuscator)VARIANT="obfuscator"; shift ;;
    *) shift ;;
    esac
  done
fi

if [[ -z "${VARIANT:-}" ]]; then
  echo "Error: must a variant --variant=<vanilla|obfuscator>"
  exit 1
fi

stage_sysroot() {

  OUT=/opt/llvm-$VARIANT/sysroot

  rm -rf "$OUT"
  mkdir -p "$OUT"

  WRAPPERS_BIN=/opt/llvm-$VARIANT/wrappers/bin

  mkdir -p $WRAPPERS_BIN
  rsync -asv '--exclude=.*.sw?' /this_dir/bin/ $WRAPPERS_BIN/

  LICENSE=/opt/llvm-$VARIANT/
  cp -v /this_dir/LICENSE $LICENSE

  mkdir -p "${OUT}/buildroot"
  m4 "-DM4_VARIANT=${VARIANT}" /this_dir/toolchainfile.cmake.m4 \
    >"${OUT}/buildroot/toolchainfile.cmake"
}

run() {

  if [[ -n "${DOCKERCEPTION:-}" ]]; then return; fi

  # shellcheck disable=SC2068
  docker run ${INTERACTIVE[@]:-} --rm \
      -v "$PWD/example:/work/example" \
      -v "$PWD/output/opt:/opt" \
      -v "$PWD:/this_dir" \
      -v $VARIANT-llvm:/work/$VARIANT-llvm \
      -v $VARIANT-llvm-build:/work/build \
      -e DOCKERCEPTION=1 \
      -e "VARIANT=$VARIANT" \
      "$DOCKER_NAMETAG-$VARIANT" \
      /bin/bash -c ". /this_dir/stage_sysroot.bash; stage_sysroot"
}

run
