# GCC / Godot notes

Some further notes and commands on compiling GCC and Godot

## Godot

use godot-3.2.2-stable to match docs for ECMAScript compilation

use godot-3.2.3-stable to match docs for Rust compilation

Godot 3.2 requires a C++ 11-compatible compiler to be built from source
Godot 4.0 will require a C++ 17-compatible compiler to be built from source

run from `path/to/godot-[version]-stable` to compile

place SConsctruct file at script root

## SCons

`scons -j6 platform=windows use_mingw=yes use_lto=yes bits=64`

`use_llvm=yes use_lld=yes`
use LLVM

`use_lto=yes`
add link-time optimization

`verbose=yes`
get more output

`bits=32`
`bits=64`
pick x86 or x86_64 for Windows

## Scoop

custom scoop manifest json file: scoop + custom gcc url + posix threads

{
"version": "9.3.0",
"homepage": "https://repo.msys2.org/mingw/x86_64/",
"url": "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-gcc-9.3.0-2-any.pkg.tar.xz",
"args": ["--enable-threads=posix"]
}
