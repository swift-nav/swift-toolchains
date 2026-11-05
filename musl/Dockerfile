FROM debian:buster-slim

ENV DEBIAN_FRONTEND=noninteractive

# Debian removed buster from deb.debian.org after end of life.
RUN sed -i 's/deb\.debian\.org/archive.debian.org/' /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y \
    build-essential \
    curl \
    file \
    git \
    sudo \
    unzip

CMD ["bash"]
