# Overview of Swift Toolchains

This collection of toolchains includes several things:

- A build of LLVM 6 for ARM and x64 for use within Buildroot to run clang-tidy (and friends)
- An abfuscating compiler for ARM using https://github.com/obfuscator-llvm/obfuscator
- GCC arm-eabi-none toolchains for "bare metal" builds

# Example usage of LLVM packages in Buildroot

To integrate with with Buildroot, see the examples in [piksi_buildroot](https://github.com/swift-nav/piksi_buildroot):
- [llvm_obfuscator.mk](https://github.com/swift-nav/piksi_buildroot/blob/v2.2.0-release/package/llvm_obfuscator/llvm_obfuscator.mk)
- [llvm_vanilla.mk](https://github.com/swift-nav/piksi_buildroot/blob/v2.2.0-release/package/llvm_vanilla/llvm_vanilla.mk)

# Piksi Firmware Toolchain
The Piksi Firmware toolchains are mirrored in the releases for this repo. When these are updated the instructions in the Piksi Firmware repository should be updated, along with any installation tools (i.e. Mac Homebrew formulas).

# Adding a new toolchain
For adding new toolchains to repo, create a Release and manually upload the toolchain as an asset. We're using GitHub releases as a stable file host for public toolchain assets.

# Copyright

```
Copyright (C) 2017 Swift Navigation Inc.
Contact: Swift Navigation <dev@swiftnav.com>

This source is subject to the license found in the file 'LICENSE' which must
be be distributed together with this source. All other rights reserved.

THIS CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND,
EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
```
