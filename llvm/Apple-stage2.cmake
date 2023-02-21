# This file sets up a CMakeCache for the second stage of a simple distribution
# bootstrap build.

set(LLVM_ENABLE_PROJECTS "clang;lld" CACHE STRING "")

set(LLVM_TARGETS_TO_BUILD Native CACHE STRING "")

set(CMAKE_BUILD_TYPE Release CACHE STRING "")

# setup toolchain
set(LLVM_INSTALL_TOOLCHAIN_ONLY ON CACHE BOOL "")
set(LLVM_TOOLCHAIN_TOOLS
  llvm-ar
  llvm-cov
  llvm-dwp
  llvm-nm
  llvm-objcopy
  llvm-objdump
  llvm-profdata
  llvm-strip
  CACHE STRING "")

set(LLVM_DISTRIBUTION_COMPONENTS
  clang
  lld
  ${LLVM_TOOLCHAIN_TOOLS}
  CACHE STRING "")
