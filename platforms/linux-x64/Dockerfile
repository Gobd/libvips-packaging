FROM amazonlinux:2023
LABEL maintainer="Kleis Auke Wolthuizen <info@kleisauke.nl>"

# Create Amazon Linux 2 (glibc 2.26) container suitable for building Linux x64 binaries

# Path settings
ENV \
  RUSTUP_HOME="/usr/local/rustup" \
  CARGO_HOME="/usr/local/cargo" \
  PATH="/usr/local/cargo/bin:$PATH"

# Build dependencies
RUN \
  yum update -y && \
  yum install -y --setopt=tsflags=nodocs \
    autoconf \
    automake \
    bzip2 \
    cmake3 \
    gcc \
    gcc-binutils \
    gcc-c++ \
    gettext \
    git \
    gperf \
    jq \
    make \
    nasm \
    patch \
    pkgconfig \
    python3-pip \
    tar \
    xz \
    && \
  curl https://sh.rustup.rs -sSf | sh -s -- -y \
    --no-modify-path \
    --profile minimal \
    && \
  pip3 install meson ninja

# Compiler settings
ENV \
  PKG_CONFIG="pkg-config --static" \
  PLATFORM="linux-x64" \
  FLAGS="-march=nehalem" \
  MESON="--cross-file=/root/meson.ini"

COPY Toolchain.cmake /root/
COPY meson.ini /root/
