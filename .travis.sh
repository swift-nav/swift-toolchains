#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

if [[ -n "${TRAVIS_PULL_REQUEST:-}" ]] || [[ -n "${TRAVIS_COMMIT_RANGE:-}" ]]; then

  if [ "$TRAVIS_PULL_REQUEST" != "false" ]; then
    file_names=$(curl "https://api.github.com/repos/$TRAVIS_REPO_SLUG/pulls/$TRAVIS_PULL_REQUEST/files" \
                  | jq '.[] | .filename' | tr '\n' ' ' | tr '"' ' ')
  else
    file_names=$( (git diff --name-only "$TRAVIS_COMMIT_RANGE" || echo "") \
                  | tr '\n' ' ' )
  fi

else
  echo "WARNING: No travis information present, assuming this is a non-travis test run..." >&2
  NO_TRAVIS=y
fi

### Setup activity ticker

(
  while true; do
    echo '...'
    sleep 10
  done
)&
TICKER_PID=$!
trap 'kill ${TICKER_PID:-} ${BUILD_PID:-}' EXIT

### base.bash

if [[ -z "${NO_TRAVIS:-}" ]]; then
  if echo "$file_names" | grep -q "Dockerfile"; then
    echo -n 'Building base image (if needed) ... '
    make base &>/tmp/base.bash.log
    echo 'DONE.'
  fi
fi

### build.bash

echo "Running build of llvm-$VARIANT... "

make "ARCH=$ARCH" NO_TTY=y VARIANT=$VARIANT build &>/tmp/build.bash.log &
BUILD_PID=$!

wait $BUILD_PID

echo 'DONE.'

### build_example.bash

if [[ $ARCH == *arm* ]] && [[ $VARIANT == obfuscator ]]; then

  echo -n 'Building example project... '
  make NO_TTY=y build-example &>/tmp/build_example.bash.log

  echo 'DONE.'
fi
