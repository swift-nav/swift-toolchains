all: normal obfuscated

normal:
	clang++ test.cc -o test-cxx -I /usr/arm-linux-gnueabihf/include -L /usr/arm-linux-gnueabi/libhf -ccc-gcc-name arm-linux-gnueabihf-gcc --target=arm-linux-gnueabihf -mfloat-abi=hard -mcpu=cortex-a9 -I /usr/arm-linux-gnueabihf/include/c++/4.8.5/ -L /usr/lib/gcc-cross/arm-linux-gnueabihf/4.8/ -I /usr/arm-linux-gnueabihf/include/c++/4.8.5/arm-linux-gnueabihf
	clang test.c -o test-c -I /usr/arm-linux-gnueabihf/include -L /usr/arm-linux-gnueabi/libhf -ccc-gcc-name arm-linux-gnueabihf-gcc --target=arm-linux-gnueabihf -mfloat-abi=hard -mcpu=cortex-a9

obfuscated:
	clang++ test.cc -o test-cxx-obf -I /usr/arm-linux-gnueabihf/include -L /usr/arm-linux-gnueabi/libhf -ccc-gcc-name arm-linux-gnueabihf-gcc --target=arm-linux-gnueabihf -mfloat-abi=hard -mcpu=cortex-a9 -mllvm -sub -mllvm -bcf -mllvm -fla -I /usr/arm-linux-gnueabihf/include/c++/4.8.5/ -L /usr/lib/gcc-cross/arm-linux-gnueabihf/4.8/ -I /usr/arm-linux-gnueabihf/include/c++/4.8.5/arm-linux-gnueabihf
	clang test.c -o test-c-obf -I /usr/arm-linux-gnueabihf/include -L /usr/arm-linux-gnueabi/libhf -ccc-gcc-name arm-linux-gnueabihf-gcc --target=arm-linux-gnueabihf -mfloat-abi=hard -mcpu=cortex-a9 -mllvm -sub -mllvm -bcf -mllvm -fla
