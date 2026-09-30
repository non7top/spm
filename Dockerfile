FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential curl ca-certificates patch perl pkg-config dpkg-dev file xz-utils \
    && rm -rf /var/lib/apt/lists/*
# A named volume takes ownership from the image's contents at its path, so
# these are created world-writable to let the non-root build uid use them.
RUN mkdir -p /usr/local/rdiff-backup /spm-home && chmod 1777 /usr/local/rdiff-backup /spm-home
ENV HOME=/spm-home
WORKDIR /app
