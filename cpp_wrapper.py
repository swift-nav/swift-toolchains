#!/usr/bin/env python

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
