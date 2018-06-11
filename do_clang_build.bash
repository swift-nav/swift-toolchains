#!/usr/bin/env bash

# Copyright (C) 2018 Swift Navigation Inc.
# Contact: Swift Navigation <dev@swiftnav.com>
#
# This source is subject to the license found in the file 'LICENSE' which must
# be be distributed together with this source. All other rights reserved.
#
# THIS CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND,
# EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.

set -euo pipefail
IFS=$'\n\t'

die_non_empty()
  { echo "*** ERROR: variable $1 must be defined and non-empty" >&2; exit 1; }

die_not_defined()
  { echo "*** ERROR: variable $1 must be defined (can be empty)" >&2; exit 1; }

[[ -n "${VARIANT:-}" ]] || die_non_empty

[[ "${VARIANT}" == "obfuscator" ]] || [[ "${VARIANT}" == "vanilla" ]] || \
  { echo "*** ERROR: invalid variant (must be one of 'vanilla', or 'obfuscator')" >&2; exit 1; }

[[ -n "${LLVM_REPO:-}" ]]              || die_non_empty LLVM_REPO
[[ -n "${LLVM_BRANCH:-}" ]]            || die_non_empty LLVM_BRANCH
[[ -n "${CMAKE_COMMAND:-}" ]]          || die_non_empty CMAKE_COMMAND
[[ -n "${CCACHE_DIR:-}" ]]             || die_non_empty CCACHE_DIR

[[ -n "${CLANG_REPO+x}" ]]             || die_not_defined CLANG_REPO
[[ -n "${CLANG_TOOLS_EXTRA_REPO+x}" ]] || die_not_defined CLANG_TOOLS_EXTRA_REPO

[[ -n "${COMPILE_CPP_WRAPPER+x}" ]]    || die_not_defined COMPILE_CPP_WRAPPER
[[ -n "${PATCH_COMMAND+x}" ]]          || die_not_defined PATCH_COMMAND

if [ ! -d "/work/$VARIANT-llvm/.git" ]; then
  git clone --depth=1 --single-branch -b "$LLVM_BRANCH" \
     "$LLVM_REPO" "$VARIANT-llvm";
else
  (cd "/work/$VARIANT-llvm" && git pull);
fi

if [ -n "${CLANG_REPO:-}" ]; then
  if [ ! -d "/work/$VARIANT-llvm/tools/clang/.git" ]; then
    git clone --depth=1 --single-branch -b "$LLVM_BRANCH" \
      "$CLANG_REPO" "$VARIANT-llvm/tools/clang";
  else
    (cd "/work/$VARIANT-llvm/tools/clang" && git pull);
  fi
fi

if [ -n "${CLANG_TOOLS_EXTRA_REPO:-}" ]; then \
  if [ ! -d "/work/$VARIANT-llvm/tools/clang-tools-extra/.git" ]; then
    git clone --depth=1 --single-branch -b "$LLVM_BRANCH" \
      "$CLANG_TOOLS_EXTRA_REPO" "$VARIANT-llvm/tools/clang-tools-extra";
  else
    (cd "/work/$VARIANT-llvm/tools/clang-tools-extra" && git pull);
  fi
fi

export CCACHE_DIR=$CCACHE_DIR
echo "CCACHE_DIR: $CCACHE_DIR"

eval "$COMPILE_CPP_WRAPPER"

cd "/work/$VARIANT-llvm"
eval "$PATCH_COMMAND"

cd /work/build

eval "$CMAKE_COMMAND"

eval ninja "$VERBOSE"
eval ninja "$VERBOSE" install
