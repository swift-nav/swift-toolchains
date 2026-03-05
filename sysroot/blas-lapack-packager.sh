#!/bin/bash

# Builds the sysroot and packages blas and lapack libraries + headers into a
# standalone tarball suitable for cc_import consumption.
#
# Usage:
#   blas-lapack-packager.sh {amd64,arm64}

set -o nounset
set -o errexit

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

DISTRO=debian
RELEASE=bullseye

SetEnvironmentVariables() {
  case $ARCH in
    amd64)
      TRIPLE=x86_64-linux-gnu
      ;;
    arm64)
      TRIPLE=aarch64-linux-gnu
      ;;
    *)
      echo "ERROR: Unsupported architecture: $ARCH"
      echo "Usage: $0 {amd64,arm64}"
      exit 1
      ;;
  esac

  BUILD_DIR="${SCRIPT_DIR}/out/sysroot-build/${RELEASE}"
  INSTALL_ROOT="${BUILD_DIR}/${RELEASE}_${ARCH}_staging"
  TARBALL="${BUILD_DIR}/${DISTRO}_${RELEASE}_${ARCH}_blas_lapack.tar.xz"
}

PackageBlasLapack() {
  if [ ! -d "${INSTALL_ROOT}" ]; then
    echo "ERROR: staging dir not found: ${INSTALL_ROOT}"
    echo "Run sysroot-creator.sh build ${ARCH} first."
    exit 1
  fi

  local lib_src="${INSTALL_ROOT}/usr/lib/${TRIPLE}"
  local inc_src="${INSTALL_ROOT}/usr/include"
  local stage="${BUILD_DIR}/blas_lapack_${ARCH}_stage"

  rm -rf "${stage}"
  mkdir -p "${stage}/lib" "${stage}/include"

  # Static libs (from blas/ and lapack/ subdirs placed there by the deb)
  cp "${lib_src}/blas/libblas.a"     "${stage}/lib/"
  cp "${lib_src}/lapack/liblapack.a" "${stage}/lib/"

  echo "Creating ${TARBALL}"
  tar -I "xz -9 -T0" -cf "${TARBALL}" -C "${stage}" .
  echo "Done: ${TARBALL}"
}

if [ $# -ne 1 ]; then
  echo "Usage: $0 {amd64,arm64}"
  exit 1
fi

ARCH=$1
SetEnvironmentVariables
"${SCRIPT_DIR}/sysroot-creator.sh" build "${ARCH}"
PackageBlasLapack
