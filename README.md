# Packaging scripts

libvips and its dependencies are provided as pre-compiled shared libraries
for the most common operating systems and CPU architectures.

## Used by NetVips

During packaging of NetVips, these binaries are fetched as tarballs from
this repository via HTTPS and stored within the NuGet package (see
[`Build.cs`](https://github.com/kleisauke/net-vips/blob/master/build/Build.cs)
for details).

Finally, the created `.nupkg` are uploaded on NuGet. You can find them here:
* [NetVips.Native.win-x64](https://www.nuget.org/packages/NetVips.Native.win-x64)
* [NetVips.Native.win-x86](https://www.nuget.org/packages/NetVips.Native.win-x86)
* [NetVips.Native.win-arm64](https://www.nuget.org/packages/NetVips.Native.win-arm64)
* [NetVips.Native.linux-x64](https://www.nuget.org/packages/NetVips.Native.linux-x64)
* [NetVips.Native.linux-arm](https://www.nuget.org/packages/NetVips.Native.linux-arm)
* [NetVips.Native.linux-arm64](https://www.nuget.org/packages/NetVips.Native.linux-arm64)
* [NetVips.Native.linux-musl-x64](https://www.nuget.org/packages/NetVips.Native.linux-musl-x64)
* [NetVips.Native.linux-musl-arm64](https://www.nuget.org/packages/NetVips.Native.linux-musl-arm64)
* [NetVips.Native.osx-x64](https://www.nuget.org/packages/NetVips.Native.osx-x64)
* [NetVips.Native.osx-arm64](https://www.nuget.org/packages/NetVips.Native.osx-arm64)

The version number of these NuGet packages is in sync with libvips' version number.

## Creating a tarball

Most people will not need to do this; proceed with caution.

Run the top-level [build script](build.sh) without parameters for help.

### Linux

One [build script](build/lin.sh) is used to (cross-)compile
the same shared libraries within multiple containers.

* [x64 glibc](platforms/linux-x64/Dockerfile)
* [x64 musl](platforms/linux-musl-x64/Dockerfile)
* [ARMv7-A glibc](platforms/linux-arm/Dockerfile)
* [ARM64v8-A glibc](platforms/linux-arm64/Dockerfile)
* [ARM64v8-A musl](platforms/linux-musl-arm64/Dockerfile)

### Windows

The output of libvips' [build-win64-mxe](https://github.com/libvips/build-win64-mxe)
static "web" releases are [post-processed](build/win.sh) within a [container](platforms/win32/Dockerfile).

### macOS

Uses a macOS virtual machine hosted by GitHub to compile the shared libraries.
The dylib files are compiled within the same build script as Linux.

* x64 (native)
* ARM64 (cross-compiled)

Dependency paths are modified to use the relative `@loader_path` with `install_name_tool`.

## Licences

These scripts are licensed under the terms of the [Apache 2.0 Licence](LICENSE).

The shared libraries contained in the tarballs are distributed under
the terms of [various licences](THIRD-PARTY-NOTICES.md), all of which
are compatible with the Apache 2.0 Licence.
