#!/usr/bin/env bash
set -e

if [ $# -lt 1 ]; then
  echo
  echo "Usage: $0 VERSION [PLATFORM]"
  echo "Build shared libraries for libvips and its dependencies via containers"
  echo
  echo "Please specify the libvips VERSION, e.g. 8.15.0"
  echo
  echo "Optionally build for only one PLATFORM, defaults to building for all"
  echo
  echo "Possible values for PLATFORM are:"
  echo "- linux-x64"
  echo "- linux-arm"
  echo "- linux-arm64"
  echo "- linux-musl-x64"
  echo "- linux-musl-arm64"
  echo "- win-x64"
  echo "- win-x86"
  echo "- win-arm64"
  echo "- osx-x64"
  echo "- osx-arm64"
  echo
  exit 1
fi

VERSION_VIPS="$1"
PLATFORM="${2:-all}"

# macOS
# Note: we intentionally don't build these binaries inside a Docker container
for flavour in osx-x64 osx-arm64; do
  if [ $PLATFORM = $flavour ] && [ "$(uname)" == "Darwin" ]; then
    echo "Building $flavour..."

    # Use Clang provided by XCode
    export CC="clang"
    export CXX="clang++"

    export VERSION_VIPS
    export PLATFORM

    # Use pkg-config provided by Homebrew
    export PKG_CONFIG="$(brew --prefix)/bin/pkg-config --static"

    # Earliest supported version of macOS
    export MACOSX_DEPLOYMENT_TARGET="10.13"

    # Added -fno-stack-check to workaround a stack misalignment bug on macOS 10.15
    # See:
    # https://forums.developer.apple.com/thread/121887
    # https://trac.ffmpeg.org/ticket/8073#comment:12
    export FLAGS="-fno-stack-check"
    # Prevent use of API newer than the deployment target
    export FLAGS+=" -Werror=unguarded-availability-new"
    export MESON="--cross-file=$PWD/platforms/$PLATFORM/meson.ini"

    if [ $PLATFORM = "osx-arm64" ]; then
      # ARM64 builds work via cross compilation from an x86_64 machine
      export CHOST="aarch64-apple-darwin"
      export FLAGS+=" -target arm64-apple-macos11"
      # macOS 11 Big Sur is the first version to support ARM-based macs
      export MACOSX_DEPLOYMENT_TARGET="11.0"
      # Set SDKROOT to the latest SDK available
      export SDKROOT=$(xcrun -sdk macosx --show-sdk-path)
    fi

    . $PWD/build/osx.sh

    exit 0
  fi
done

# Is docker available?
if ! [ -x "$(command -v docker)" ]; then
  echo "Please install docker"
  exit 1
fi

# Update base images
for baseimage in amazonlinux:2023; do
  docker pull $baseimage
done

# Linux (x64, ARMv7 and ARM64v8)
for flavour in linux-x64 linux-arm64; do
  if [ $PLATFORM = "all" ] || [ $PLATFORM = $flavour ]; then
    if [ $PLATFORM = "linux-x64" ] && [ $(uname -m) == "arm64" ] ; then
      echo "Cross building $flavour..."
      docker build --progress plain --platform linux/amd64 --cache-from vips-dev-$flavour -t vips-dev-$flavour platforms/$flavour
      docker run --platform linux/amd64 --rm -e "VERSION_VIPS=$VERSION_VIPS" -e ROSETTA=true -e VERSION_LATEST_REQUIRED -v $PWD:/packaging vips-dev-$flavour sh -c "/packaging/build/lin.sh"
    else 
      echo "Building $flavour..."
      docker build --progress plain --cache-from vips-dev-$flavour -t vips-dev-$flavour platforms/$flavour
      docker run --rm -e "VERSION_VIPS=$VERSION_VIPS" -e VERSION_LATEST_REQUIRED -v $PWD:/packaging vips-dev-$flavour sh -c "/packaging/build/lin.sh"
    fi
  fi
done
