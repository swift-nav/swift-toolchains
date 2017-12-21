# Copyright (C) 2017 Swift Navigation Inc.
# Contact: Swift Navigation <dev@swiftnav.com>
#
# This source is subject to the license found in the file 'LICENSE' which must
# be be distributed together with this source. All other rights reserved.
#
# THIS CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND,
# EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.

OBFUSCATE_OPS := -mllvm -sub -mllvm -bcf -mllvm -fla

all: normal obfuscated

normal:
	arm-linux-gnueabihf-clang test.c -o test-c 
	arm-linux-gnueabihf-clang++ test.cc -o test-cxx

obfuscated:
	arm-linux-gnueabihf-clang test.c -o test-c $(OBFUSCATE_OPS)
	arm-linux-gnueabihf-clang++ test.cc -o test-cxx $(OBFUSCATE_OPS)
