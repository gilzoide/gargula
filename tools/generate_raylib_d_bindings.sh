#!/bin/sh

script_root=$(dirname $(realpath $0))

raylib_h="$script_root/../subprojects/raylib/src/raylib.h"

pushd $script_root

dstep --alias-enum-members "$raylib_h" -o d_wrappers/raylib.d
# Fix anonymous enum aliases like "alias SAPP_MAX_TOUCHPOINTS = .SAPP_MAX_TOUCHPOINTS;"
#sed -i '/alias \w* = \.\w*;/d' d_wrappers/*.d

# Fix initial float values as 0 instead of NaN
sed -i -E 's/^(\s+float[^*][^;]+);/\1 = 0;/g' d_wrappers/*.d
# Fix initial value for Camera2D.zoom
sed -i -E 's/float zoom = 0;/float zoom = 1;/g' d_wrappers/*.d
# Fix "Temporal hack" aliases
sed -i -E 's/^enum (\w+ = \w+;)/alias \1/g' d_wrappers/*.d

popd
