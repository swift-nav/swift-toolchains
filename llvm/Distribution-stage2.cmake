# This file sets up a CMakeCache for the second stage of a simple distribution
# bootstrap build.

set(LLVM_ENABLE_PROJECTS "clang;clang-tools-extra;lld" CACHE STRING "")
set(LLVM_ENABLE_RUNTIMES "compiler-rt;libcxx;libcxxabi;libunwind" CACHE STRING "")

set(COMPILER_RT_BUILD_BUILTINS ON CACHE BOOL "")

set(LLVM_TARGETS_TO_BUILD Native CACHE STRING "")

set(CMAKE_BUILD_TYPE RelWithDebInfo CACHE STRING "")
set(CMAKE_C_FLAGS_RELWITHDEBINFO "-O3 -gline-tables-only -DNDEBUG" CACHE STRING "")
set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "-O3 -gline-tables-only -DNDEBUG" CACHE STRING "")

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
  llvm-symbolizer
  CACHE STRING "")

set(LLVM_DISTRIBUTION_COMPONENTS
  clang
  lld
  builtins
  runtimes
  clang-resource-headers
  clang-tidy
  ${LLVM_TOOLCHAIN_TOOLS}
  CACHE STRING "")
