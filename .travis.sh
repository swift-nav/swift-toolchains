#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

if [ "$TRAVIS_PULL_REQUEST" != "false" ]; then
  file_names=`curl "https://api.github.com/repos/$TRAVIS_REPO_SLUG/pulls/$TRAVIS_PULL_REQUEST/files" | jq '.[] | .filename' | tr '\n' ' ' | tr '"' ' '`
else
  file_names=`(git diff --name-only $TRAVIS_COMMIT_RANGE || echo "") | tr '\n' ' '`
fi

if echo $file_names | grep -q "Dockerfile"; then
	./base.bash &>/tmp/base.bash.log
fi

./build.bash --arch=$ARCH &>/tmp/build.bash.log

if [[ $ARCH = arm ]]; then
  ./build_example.bash &>/tmp/build_example.bash.log
fi
