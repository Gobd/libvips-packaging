FROM arm64v8/amazonlinux:2023
LABEL maintainer="Kleis Auke Wolthuizen <info@kleisauke.nl>"

# Create Amazon Linux 2 (glibc 2.26) container suitable for building Linux ARM64v8-A binaries

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
    gcc-c++ \
    gettext \
    git \
    gperf \
    jq \
    make \
    patch \
    pkgconfig \
    python3-pip \
    tar \
    xz \
    && \
  curl https://sh.rustup.rs -sSf | sh -s -- -y \
    --no-modify-path \
    --profile minimal \
    --default-host aarch64-unknown-linux-gnu \
    && \
  pip3 install meson ninja

# Compiler settings
ENV \
  PKG_CONFIG="pkg-config --static" \
  PLATFORM="linux-arm64" \
  FLAGS="-march=armv8-a" \
  MESON="--cross-file=/root/meson.ini"

COPY Toolchain.cmake /root/
COPY meson.ini /root/
