#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

die_non_empty()
  { echo "*** ERROR: variable $1 must be defined and non-empty" >&2; exit 1; }

die_not_defined()
  { echo "*** ERROR: variable $1 must be defined (can be empty)" >&2; exit 1; }

[[ -n "${VARIANT}" ]] || die_not_defined

[[ "${VARIANT}" == "obfuscator" ]] || [[ "${VARIANT}" == "vanilla" ]] || \
  { echo "*** ERROR: invalid variant (must be one of 'vanilla', or 'obfuscator')" >&2; exit 1; }

[[ -n "${LLVM_REPO}" ]]                || die_non_empty LLVM_REPO
[[ -n "${LLVM_BRANCH}" ]]              || die_non_empty LLVM_BRANCH
[[ -n "${CMAKE_COMMAND}" ]]            || die_non_empty CMAKE_COMMAND

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

eval "$COMPILE_CPP_WRAPPER"

cd "/work/$VARIANT-llvm"
eval "$PATCH_COMMAND"

cd /work/build

eval "$CMAKE_COMMAND"

if [[ -n "$VERBOSE" ]]; then
  ninja -v
  ninja -v install
else
  ninja 
  ninja install
fi
