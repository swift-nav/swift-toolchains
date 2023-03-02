# This file sets up a CMakeCache for Apple-style stage2 bootstrap. It is
# specified by the stage1 build.

set(LLVM_ENABLE_PROJECTS "clang;clang-tools-extra" CACHE STRING "")
set(LLVM_ENABLE_RUNTIMES "compiler-rt;libcxx;libcxxabi;libunwind" CACHE STRING "")

set(LLVM_TARGETS_TO_BUILD AArch64 CACHE STRING "") 
set(PACKAGE_VENDOR Apple CACHE STRING "")

set(CMAKE_MACOSX_RPATH ON CACHE BOOL "")

set(CMAKE_BUILD_TYPE RelWithDebInfo CACHE STRING "")
set(CMAKE_C_FLAGS_RELWITHDEBINFO "-O3 -gline-tables-only -DNDEBUG" CACHE STRING "")
set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "-O3 -gline-tables-only -DNDEBUG" CACHE STRING "")

# Generating Xcode toolchains is useful for developers wanting to build and use
# clang without installing over existing tools.
# set(LLVM_CREATE_XCODE_TOOLCHAIN ON CACHE BOOL "")

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
    builtins
    runtimes
    clang-resource-headers
    clang-tidy
    ${LLVM_TOOLCHAIN_TOOLS}
    CACHE STRING "")

# test args

set(LLVM_LIT_ARGS "--xunit-xml-output=testresults.xunit.xml -v" CACHE STRING "")