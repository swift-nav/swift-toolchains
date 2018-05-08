SCRIPTS := .travis.sh \
					 base.bash \
					 build.bash \
					 build_example.bash \
					 publish.sh \
					 run_build_shell.bash \
					 stage_sysroot.bash \

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

base: check-base
	$(CURDIR)/base.bash $(NO_TTY_ARG)

build: check-build
	$(CURDIR)/build.bash $(NO_TTY_ARG) --arch=$(ARCH)

stage: check-stage_sysroot
	$(CURDIR)/stage_sysroot.bash $(NO_TTY_ARG)

build-example: check-build_example
	$(CURDIR)/build_example.bash $(NO_TTY_ARG)

run: check-run_build_shell
	$(CURDIR)/run_build_shell.bash $(NO_TTY_ARG)

clean:
	docker volume rm obfuscator-llvm-build || :
	docker volume rm obfuscator-llvm || :
	sudo rm -rf output/*
