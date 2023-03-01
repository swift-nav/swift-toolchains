# This file sets up a CMakeCache for a simple distribution bootstrap build.

#Enable LLVM projects and runtimes
set(LLVM_ENABLE_PROJECTS "clang" CACHE STRING "")
set(LLVM_ENABLE_RUNTIMES "compiler-rt;libcxx;libcxxabi" CACHE STRING "")

set(COMPILER_RT_BUILD_BUILTINS              ON CACHE BOOL "")

set(LLDB_ENABLE_CURSES 0 CACHE STRING "")
set(CLANG_DEFAULT_RTLIB "compiler-rt" CACHE STRING "")
set(LLVM_BUILD_COMPILER_RT "ON" CACHE STRING "")
# set(LIBUNWIND_USE_COMPILER_RT ON CACHE STRING "")
set(LIBCXXABI_USE_COMPILER_RT "ON" CACHE STRING "")
set(LIBCXX_USE_COMPILER_RT "ON" CACHE STRING "")

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
  # lld
  # builtins
  runtimes
  # clang-resource-headers
  # ${LLVM_TOOLCHAIN_TOOLS}
  CACHE STRING "")


# Only build the native target in stage1 since it is a throwaway build.
set(LLVM_TARGETS_TO_BUILD Native CACHE STRING "")

# Optimize the stage1 compiler, but don't LTO it because that wastes time.
set(CMAKE_BUILD_TYPE Release CACHE STRING "")

# Setup vendor-specific settings.
set(PACKAGE_VENDOR LLVM.org CACHE STRING "")

# # Setting up the stage2 LTO option needs to be done on the stage1 build so that
# # the proper LTO library dependencies can be connected.
# set(BOOTSTRAP_LLVM_ENABLE_LTO ON CACHE BOOL "")

# if (NOT APPLE)
#   # Since LLVM_ENABLE_LTO is ON we need a LTO capable linker
#   set(BOOTSTRAP_LLVM_ENABLE_LLD ON CACHE BOOL "")
# endif()

# # Expose stage2 targets through the stage1 build configuration.
# set(CLANG_BOOTSTRAP_TARGETS
#   distribution
#   install-distribution
#   clang CACHE STRING "")

# # Setup the bootstrap build.
# set(CLANG_ENABLE_BOOTSTRAP ON CACHE BOOL "")

# set(CLANG_BOOTSTRAP_CMAKE_ARGS
#   -C ${CMAKE_CURRENT_LIST_DIR}/Distribution-stage2.cmake
#   CACHE STRING "")
