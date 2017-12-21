SCRIPTS := .travis.sh \
					 base.bash \
					 build.bash \
					 build_example.bash \
					 publish.sh \
					 run_build_shell.bash \
					 stage_sysroot.bash \

check:
	docker run -v $(CURDIR):/mnt koalaman/shellcheck -x $(SCRIPTS)

check-%:
	docker run -v $(CURDIR):/mnt koalaman/shellcheck -x $*.bash

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
