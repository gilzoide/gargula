#!/bin/sh

script_root=$(dirname $(realpath $0))

stdio_file="$script_root/druntime/src/core/stdc/stdio.d"
sed -i 's/CRuntime_Microsoft/MinGW/g' "$stdio_file"
