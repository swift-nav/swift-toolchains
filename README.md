# Overview of llvm-obfuscator-arm

[![Build Status](https://travis-ci.org/swift-nav/llvm-obfuscator-arm.svg?branch=master)](https://travis-ci.org/swift-nav/llvm-obfuscator-arm)

Obfuscating compiler for ARM using https://github.com/obfuscator-llvm/obfuscator.

This is designed to be integrated with buildroot in order to provide an 
obfuscating compiler for components that need it.

# Example usage

To integrate with with buildroot, a package.mk will look like this (the `*_SOURCE`
var below is important, you'll need to interact with the GitHub API to find it
when upgrading to a new release):

```make
HOST_LLVM_OBFUSCATOR_VERSION = v4
HOST_LLVM_OBFUSCATOR_SOURCE = 5086675

HOST_LLVM_OBFUSCATOR_SITE = https://$(GITHUB_TOKEN):@api.github.com/repos/swift-nav/llvm-obfuscator-arm/releases/assets
HOST_LLVM_OBFUSCATOR_METHOD = wget
HOST_LLVM_OBFUSCATOR_DL_OPTS = --auth-no-challenge --header='Accept:application/octet-stream'

HOST_LLVM_OBFUSCATOR_ACTUAL_SOURCE_TARBALL = llvm-obfuscator-arm-$(HOST_LLVM_OBFUSCATOR_VERSION).tar.xz
HOST_LLVM_OBFUSCATOR_DEPENDENCIES = host-xz

define HOST_LLVM_OBFUSCATOR_PRE_EXTRACT_FIXUP
	if ! [ -e $(DL_DIR)/$(HOST_LLVM_OBFUSCATOR_ACTUAL_SOURCE_TARBALL) ]; then \
		mv -v $(DL_DIR)/$(HOST_LLVM_OBFUSCATOR_SOURCE) $(DL_DIR)/$(HOST_LLVM_OBFUSCATOR_ACTUAL_SOURCE_TARBALL); fi
	$(eval HOST_LLVM_OBFUSCATOR_SOURCE=$(HOST_LLVM_OBFUSCATOR_ACTUAL_SOURCE_TARBALL))
endef

HOST_LLVM_OBFUSCATOR_PRE_EXTRACT_HOOKS += HOST_LLVM_OBFUSCATOR_PRE_EXTRACT_FIXUP

define HOST_LLVM_OBFUSCATOR_INSTALL_CMDS
	mkdir -p $(HOST_DIR)/opt/llvm-obfuscator
	rsync -az $(@D)/opt/llvm-obfuscator/ $(HOST_DIR)/opt/llvm-obfuscator/
endef

LLVM_OBF_CC = $(HOST_DIR)/opt/llvm-obfuscator/wrappers/bin/arm-linux-gnueabihf-clang
LLVM_OBF_CXX = $(HOST_DIR)/opt/llvm-obfuscator/wrappers/bin/arm-linux-gnueabihf-clang++

$(eval $(host-generic-package))
```

To upgrade to a new release of the compiler, use the GitHub API to find the
new artifact ID (uses [jq](https://stedolan.github.io/jq/)):

```bash
> export GITHUB_TOKEN=... # your GitHub auth token
> curl -sSL -H "Authorization: token $GITHUB_TOKEN" -H "Accept: application/vnd.github.v3.raw" https://api.github.com/repos/swift-nav/llvm-obfuscator-arm/releases/latest | jq '.assets[0].id,.assets[0].name,.tag_name'

5086675
"llvm-obfuscator-arm.txz"
"v4"
```

# Copyright Notice

```
Copyright (C) 2017 Swift Navigation Inc.
Contact: Swift Navigation <dev@swiftnav.com>

This source is subject to the license found in the file 'LICENSE' which must
be be distributed together with this source. All other rights reserved.

THIS CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND,
EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
```
