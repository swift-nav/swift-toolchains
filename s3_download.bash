#!/bin/bash

# Copyright (C) 2016 Swift Navigation Inc.
# Contact: Fergus Noble <fergus@swiftnav.com>
#
# This source is subject to the license found in the file 'LICENSE' which must
# be be distributed together with this source. All other rights reserved.
#
# THIS CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND,
# EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
#
# Script for downloading firmware and NAP binaries from S3 to be incorporated
# into the Linux image.

set -xe

REPO="${PWD##*/}"
BUCKET="${BUCKET:-llvm-obfuscator-arm}"

BUILD_VERSION="$(describe_repo.bash)"
BUILD_PATH="$REPO/$BUILD_VERSION"
if [[ ! -z "$PRODUCT_VERSION" ]]; then
    BUILD_PATH="$BUILD_PATH/$PRODUCT_VERSION"
fi
if [[ ! -z "$PRODUCT_REV" ]]; then
    BUILD_PATH="$BUILD_PATH/$PRODUCT_REV"
fi
if [[ ! -z "$PRODUCT_TYPE" ]]; then
    BUILD_PATH="$BUILD_PATH/$PRODUCT_TYPE"
fi

echo "Downloading $* to $BUILD_PATH"

for file in "$@"; do
    KEY="$BUILD_PATH/$(basename "$file")"
    OBJECT="s3://$BUCKET/$KEY"
    aws s3 cp "$OBJECT" "$file" 
done
