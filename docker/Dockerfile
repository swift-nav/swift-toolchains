FROM debian:buster-slim

ENV DEBIAN_FRONTEND=noninteractive

ARG SCCACHE_URL=https://github.com/mozilla/sccache/releases/download/v0.3.0/sccache-v0.3.0-x86_64-unknown-linux-musl.tar.gz

ENV SCCACHE_BUCKET='swiftnav-sccache'

RUN apt-get update && \
    apt-get install -y \
    build-essential \
    curl \
    file \
    git \
    sudo \
    unzip \
    python3-pip && \
    pip3 install awscli upgrade \
    && curl -sSL -o /tmp/sccache.tgz "${SCCACHE_URL}" \
    && mkdir /tmp/sccache \
    && tar --strip-components=1 -C /tmp/sccache -xzf /tmp/sccache.tgz \
    && chmod +x /tmp/sccache/sccache \
    && mv /tmp/sccache/sccache /usr/local/bin
