#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

if [ "$TRAVIS_PULL_REQUEST" != "false" ]; then
  file_names=`curl "https://api.github.com/repos/$TRAVIS_REPO_SLUG/pulls/$TRAVIS_PULL_REQUEST/files" | jq '.[] | .filename' | tr '\n' ' ' | tr '"' ' '`
else
  file_names=`(git diff --name-only $TRAVIS_COMMIT_RANGE || echo "") | tr '\n' ' '`
fi

if echo $file_names | grep -q "Dockerfile"; then

	./base.bash 2>&1 | tee /tmp/base.bash.log
fi

./build.bash --arch=$ARCH &>/tmp/build.bash.log &
BUILD_PID=$!

(
  while `true`; do
    echo '...'
    sleep 1
  done
)&
TICKER_PID=$!

wait $BUILD_PID
kill $TICKER_PID

if [[ $ARCH = arm ]]; then
  ./build_example.bash &>/tmp/build_example.bash.log
fi
