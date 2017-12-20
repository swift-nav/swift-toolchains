#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

if [ "$TRAVIS_PULL_REQUEST" != "false" ]; then
  file_names=`curl "https://api.github.com/repos/$TRAVIS_REPO_SLUG/pulls/$TRAVIS_PULL_REQUEST/files" | jq '.[] | .filename' | tr '\n' ' ' | tr '"' ' '`
else
  file_names=`(git diff --name-only $TRAVIS_COMMIT_RANGE || echo "") | tr '\n' ' '`
fi

echo 'Running ./base.bash ...'

if echo $file_names | grep -q "Dockerfile"; then
  ./base.bash 2>&1 | tee /tmp/base.bash.log
fi

echo 'DONE running ./base.bash'

echo 'Running ./build.bash ...'

./build.bash --arch=$ARCH --no-tty &>/tmp/build.bash.log &
BUILD_PID=$!

(
  while `true`; do
    echo '...'
    sleep 10
  done
)&
TICKER_PID=$!

wait $BUILD_PID
kill $TICKER_PID || :

echo 'DONE running ./build.bash'

if [[ $ARCH = arm ]]; then

  echo 'Running ./build_example.bash ...'
  ./build_example.bash --no-tty &>/tmp/build_example.bash.log

  echo 'DONE running ./build_build.bash'
fi
