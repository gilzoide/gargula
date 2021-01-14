#!/bin/sh

script_root=$(dirname $(realpath $0))
project_root="$script_root/.."

raylib_h="$project_root/subprojects/raylib/src/raylib.h"
raylib_d="$project_root/source/gargula/wrapper/raylib.d"

pushd $project_root

dstep --package gargula.wrapper \
    --skip RL_MALLOC \
    --skip RL_CALLOC \
    --skip RL_REALLOC \
    --skip RL_FREE \
    --skip CLITERAL \
    "$raylib_h" -o "$raylib_d"

colors=$(sed -n -E '/CLITERAL\(Color\)/s/#define (\w+).+\{(.+)\}/enum Color \1 = [\2];  /p' "$raylib_h")

sedscript=$(echo '
# Import bettercmath and replace Vector*, Matrix and Color definitions
/^import core.stdc.stdarg;/a import bettercmath.vector : _Vector = Vector;\nimport bettercmath.matrix : _Matrix = Matrix;
/^struct Vector2/,/^}/c alias Vector2 = _Vector!(float, 2);
/^struct Vector3/,/^}/c alias Vector3 = _Vector!(float, 3);
/^struct Vector4/,/^}/c alias Vector4 = _Vector!(float, 4);
/^struct Matrix/,/^}/c  alias Matrix = _Matrix!(float, 4);
/^struct Color/,/^}/c   alias Color = _Vector!(ubyte, 4);

# Fix initial float values as 0 instead of NaN
s/^(\s+float[^*][^;]+);/\1 = 0;/g

# Fix initial value for Camera2D.zoom
s/float zoom = 0;/float zoom = 1;/g

# Fix "Temporal hack" aliases
s/^enum (\w+ = \w+;)/alias \1/g

# Add color constants
/Some Basic Colors/r/dev/stdin
')

echo "$colors" | sed -i -E "$sedscript" "$raylib_d"

popd
