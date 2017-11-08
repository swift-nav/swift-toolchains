#!/bin/bash

# Copyright (C) 2017 Swift Navigation Inc.
# Contact: Swift Navigation <dev@swiftnav.com>
#
# This source is subject to the license found in the file 'LICENSE' which must
# be be distributed together with this source. All other rights reserved.
#
# THIS CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND,
# EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.

DOCKER_NAMETAG=swiftnav/arm-llvm-obf:4.0

docker build -f Dockerfile -t $DOCKER_NAMETAG .

docker login --username="$DOCKER_USER" --password="$DOCKER_PASS"
docker push $DOCKER_NAMETAG
