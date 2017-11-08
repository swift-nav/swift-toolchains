#!/bin/bash

if [ "$TRAVIS_PULL_REQUEST" != "false" ]; then
  file_names=`curl "https://api.github.com/repos/$TRAVIS_REPO_SLUG/pulls/$TRAVIS_PULL_REQUEST/files" | jq '.[] | .filename' | tr '\n' ' ' | tr '"' ' '`
else
  file_names=`(git diff --name-only $TRAVIS_COMMIT_RANGE || echo "") | tr '\n' ' '`
fi

if echo $file_names | grep -q "Dockerfile"; then
	./base.bash
fi

./build.bash --arch=$ARCH
[[ $ARCH = arm ]] && ./build_example.bash
