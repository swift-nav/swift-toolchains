#!/usr/bin/env python

# Copyright (C) 2017 Swift Navigation Inc.
# Contact: Swift Navigation <dev@swiftnav.com>
#
# This source is subject to the license found in the file 'LICENSE' which must
# be be distributed together with this source. All other rights reserved.
#
# THIS CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND,
# EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.

import os
import sys

#cpp_path = "/usr/bin/arm-linux-gnueabihf-g++-4.8"
cpp_path = "/usr/bin/g++"

new_argv = sys.argv[:]
new_argv[0] = cpp_path

args = str.join(" ", sys.argv)

if (("-o lib/libLTO.so.4.0.1" in args and "lib/libLLVMObfuscation.a" in args) or
    ("-o bin/llvm-lto" in args and "lib/libLLVMObfuscation.a" in args)):

    sys.stderr.write("********************** HACK IMMINENT **************************\n")
    sys.stderr.write("********************** HACK IMMINENT **************************\n")
    sys.stderr.write("********************** HACK IMMINENT **************************\n")

    new_argv.append("lib/libLLVMTransformUtils.a")

os.execv(cpp_path, new_argv)
