#!/bin/sh

script_root=$(dirname $(realpath $0))

build_ninja="$script_root/../build/win32/build.ninja"
sed -i -E 's/-m(32|64) //g' "$build_ninja"
