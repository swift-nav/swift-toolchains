SCRIPTS := .travis.sh \
					 base.bash \
					 build.bash \
					 build_example.bash \
					 publish.sh \
					 run_build_shell.bash \
					 stage_sysroot.bash \
					 do_clang_build.bash \
					 push_ccache.bash \
					 pull_ccache.bash \
					 s3_download.bash \

all: check base build

cpp_wrapper: cpp_wrapper.c
	gcc -O3 -std=c99 -Wall cpp_wrapper.c -o cpp_wrapper

check:
	docker run --rm -v $(CURDIR):/mnt koalaman/shellcheck -x $(SCRIPTS)

check-%:
	docker run --rm -v $(CURDIR):/mnt koalaman/shellcheck -x $*.bash

ifeq ($(NO_TTY),y)
NO_TTY_ARG := --no-tty
else
NO_TTY_ARG :=
endif

arm-linux-musleabihf:
	docker build --tag 'rust-musl-cross' musl
	docker run --rm -v $(CURDIR):/mnt/workspace -w /mnt/workspace rust-musl-cross musl/build.sh arm-linux-musleabihf

aarch64-linux-musl:
	docker build --tag 'rust-musl-cross' musl
	docker run --rm -v $(CURDIR):/mnt/workspace -w /mnt/workspace rust-musl-cross musl/build.sh aarch64-linux-musl

x86_64-linux-musl:
	docker build --tag 'rust-musl-cross' musl
	docker run --rm -v $(CURDIR):/mnt/workspace -w /mnt/workspace rust-musl-cross musl/build.sh x86_64-linux-musl

base: check-base
	$(CURDIR)/base.bash $(NO_TTY_ARG)

build: check-build
	$(CURDIR)/build.bash $(NO_TTY_ARG) --arch=$(ARCH) --variant=$(VARIANT)

stage: check-stage_sysroot
	$(CURDIR)/stage_sysroot.bash $(NO_TTY_ARG)

build-example: check-build_example
	$(CURDIR)/build_example.bash $(NO_TTY_ARG)

run: check-run_build_shell
	$(CURDIR)/run_build_shell.bash $(NO_TTY_ARG)

clean-vanilla-build:
	docker volume rm vanilla-llvm-build || :
	docker volume rm vanilla-llvm-ccache || :

clean-vanilla-src:
	docker volume rm vanilla-llvm || :

clean-vanilla: clean-vanilla-build clean-vanilla-src

clean-obfuscator-build:
	docker volume rm obfuscator-llvm-build || :
	docker volume rm obfuscator-llvm-ccache || :

clean-obfuscator-src:
	docker volume rm obfuscator-llvm || :

clean-obfuscator: clean-obfuscator-build clean-obfuscator-src

clean-build: clean-vanilla clean-obfuscator

clean: clean-build
	sudo rm -rf output/*
