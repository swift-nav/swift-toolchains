OBFUSCATE_OPS := -mllvm -sub -mllvm -bcf -mllvm -fla

all: normal obfuscated

normal:
	arm-linux-gnueabihf-clang++ test.cc -o test-cxx
	arm-linux-gnueabihf-clang test.c -o test-c 

obfuscated:
	arm-linux-gnueabihf-clang++ test.cc -o test-cxx $(OBFUSCATE_OPS)
	arm-linux-gnueabihf-clang test.c -o test-c $(OBFUSCATE_OPS)
