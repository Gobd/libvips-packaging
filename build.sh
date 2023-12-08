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
  echo "- linux-arm64"
  echo
  exit 1
fi

VERSION_VIPS="$1"
PLATFORM="${2:-all}"

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
