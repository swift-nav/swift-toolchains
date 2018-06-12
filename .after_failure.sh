#!/usr/bin/env bash

set -x

if [[ -e /tmp/base.bash.log ]]; then
  cp /tmp/base.bash.log /tmp/$VARIANT-base.bash.log
  ./publish.sh /tmp/$VARIANT-base.bash.log
  tail -n 200 /tmp/base.bash.log
fi

if [[ -e /tmp/build.bash.log ]]; then
  cp /tmp/build.bash.log /tmp/$VARIANT-build.bash.log
  ./publish.sh /tmp/$VARIANT-build.bash.log
  tail -n 200 /tmp/build.bash.log;
fi

if [[ -e /tmp/build_example.bash.log ]]; then
  cp /tmp/build_example.bash.log /tmp/$VARIANT-build_example.bash.log
  ./publish.sh /tmp/$VARIANT-build_example.bash.log
  tail -n 200 /tmp/build_example.bash.log;
fi
