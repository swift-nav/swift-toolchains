/* Copyright (C) 2017 Swift Navigation Inc.
 * Contact: Swift Navigation <dev@swiftnav.com>
 *
 * This source is subject to the license found in the file 'LICENSE' which must
 * be be distributed together with this source. All other rights reserved.
 *
 * THIS CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND,
 * EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
 */

#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <unistd.h>

#define DEBUG

//const char* real_cpp_path = "/toolchain/x86/bin/x86_64-linux-g++";
const char* real_cpp_path = "/toolchain/x86/bin/x86_64-buildroot-linux-gnu-c++.br_real";
const char* new_argv_entry = "lib/libLLVMTransformUtils.a";

int main(int argc, const char* argv[]) {

  size_t args_str_size = 0;
  size_t* lengths = (size_t*) malloc(argc*sizeof(size_t));

  for (int x = 0; x < argc; x++) {
    lengths[x] = strlen(argv[x]);
    args_str_size += lengths[x];
  }

#ifdef DEBUG
  fprintf(stderr, "%zu\n", args_str_size);
#endif

  // Make space for spaces in between argument values + null terminator
  args_str_size += (argc - 1) + 1;

  char* all_args_buf = (char*) malloc(args_str_size);
  char* p = all_args_buf;

  for (int x = 0; x < argc; x++) {
    memcpy(p, argv[x], lengths[x]);
    p += lengths[x];
    *p++ = ' ';
  }

  // Null terminate the string
  *p = '\0';

#ifdef DEBUG
  fprintf(stderr, "All args: %s\n", all_args_buf);
#endif

  bool append_new_arg = false;

  if ( (strstr(all_args_buf, "-o lib/libLTO.so.4.0.1")   != NULL &&
        strstr(all_args_buf, "lib/libLLVMObfuscation.a") != NULL    )
      ||
       (strstr(all_args_buf, "-o bin/llvm-lto")          != NULL &&
        strstr(all_args_buf, "lib/libLLVMObfuscation.a") != NULL    ) )
  {
    fprintf(stderr, "********************** HACK IMMINENT **************************\n");
    fprintf(stderr, "********************** HACK IMMINENT **************************\n");
    fprintf(stderr, "********************** HACK IMMINENT **************************\n");

    append_new_arg = true;
  }

  argv[0] = real_cpp_path;
  int execv_ret;

  if (append_new_arg) {

    int new_argc = argc + 1;
    const char** new_argv = malloc( (new_argc+1) * sizeof(char*) );

    for (int x = 0; x < argc; x++) {

      size_t length = x == 0 ? strlen(real_cpp_path) : (lengths[x] + 1);

      new_argv[x] = (char*) malloc(length * sizeof(char));
      memcpy((void*) new_argv[x], argv[x], length * sizeof(char));
    }

    size_t new_argv_len = strlen(new_argv_entry) + 1;
    new_argv[new_argc - 1] = malloc(new_argv_len * sizeof(char));

    memcpy((void*) new_argv[new_argc - 1], new_argv_entry, new_argv_len);

    new_argv[new_argc] = NULL; 
    
    argc = new_argc;
    argv = new_argv;

    execv_ret = execv(real_cpp_path, (char*const*)new_argv);
  }
  else {
    execv_ret = execv(real_cpp_path, (char*const*)argv);
  }

#if 0 // This causes a heap corruption error trigger?
  free(lengths);
  free(all_args_buf);
#endif

  fprintf(stderr, "execv() failure: %d\n", execv_ret);
  return -42;
}
