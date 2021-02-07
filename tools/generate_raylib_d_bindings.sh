#!/bin/sh

script_root=$(dirname $(realpath $0))
project_root="$script_root/.."

raylib_h="$project_root/subprojects/raylib/src/raylib.h"
raylib_d="$project_root/source/gargula/wrapper/raylib.d"
raymath_h="$project_root/subprojects/raylib/src/raymath.h"
raymath_d="$project_root/source/gargula/wrapper/raymath.d"
rlgl_h="$project_root/subprojects/raylib/src/rlgl.h"
rlgl_d="$project_root/source/gargula/wrapper/rlgl.d"
physac_h="$project_root/subprojects/raylib/src/physac.h"
physac_d="$project_root/source/gargula/wrapper/physac.d"

pushd $project_root

################################################################
# raylib
################################################################
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
/^import core.stdc.stdarg;/a import bettercmath.vector : _Vector = Vector;\nimport bettercmath.matrix : _Matrix = Matrix;\nimport bettercmath.box : _BoundingBox = BoundingBox, BoundingBoxOptions;
/^struct Vector2/,/^}/c alias Vector2 = _Vector!(float, 2);
/^struct Vector3/,/^}/c alias Vector3 = _Vector!(float, 3);
/^struct Vector4/,/^}/c alias Vector4 = _Vector!(float, 4);
/^struct Matrix/,/^}/c  alias Matrix = _Matrix!(float, 4);
/^struct Color/,/^}/c   alias Color = _Vector!(ubyte, 4);
/^struct Rectangle/,/^}/c  alias Rectangle = _BoundingBox!(float, 2, BoundingBoxOptions.storeSize);
/^struct BoundingBox/,/^}/c  alias BoundingBox = _BoundingBox!(float, 3);

# Add "@nogc nothrow" function attributes
/^(extern \(C\))/a @nogc nothrow:

# Fix initial float values as 0 instead of NaN
s/^(\s+float[^*][^;]+);/\1 = 0;/

# Fix initial value for Camera2D.zoom
s/float zoom = 0;/float zoom = 1;/

# Set initial value for Camera3D.up to [0, 1, 0]
s/(Vector3 up)/\1 = Vector3(0, 1, 0)/

# Set initial value for Transform.rotation to [0, 0, 0, 1]
s/^(\s+Quaternion rotation)/\1 = Quaternion(0, 0, 0, 1)/
# Set initial value for Transform.scale to [1, 1, 1]
s/^(\s+Vector3 scale)/\1 = Vector3(1, 1, 1)/

# Fix "Temporal hack" aliases
s/^enum (\w+ = \w+;)/alias \1/

# Remove enum type names, to use them directly from D code
s/enum [^;]*$/enum/

# Remove some enum namespaces usage just removed
s/(enum \w* = )[a-zA-Z_]*\.([a-zA-Z_]*;)/\1\2/

# Add color constants
/Some Basic Colors/r/dev/stdin
')

echo "$colors" | sed -i -E "$sedscript" "$raylib_d"

################################################################
# raymath
################################################################
dstep --package gargula.wrapper \
    --skip RL_MALLOC \
    --skip RL_CALLOC \
    --skip RL_REALLOC \
    --skip RL_FREE \
    --skip CLITERAL \
    "$raymath_h" -o "$raymath_d"

sedscript=$(echo '
# Import raylib wrapper
/^(extern \(C\))/i import gargula.wrapper.raylib;

# Add "@nogc nothrow" function attributes
/^(extern \(C\))/a @nogc nothrow:
')

sed -i -E "$sedscript" "$raymath_d"

################################################################
# rlgl
################################################################
dstep --package gargula.wrapper \
    --skip RL_MALLOC \
    --skip RL_CALLOC \
    --skip RL_REALLOC \
    --skip RL_FREE \
    --skip CLITERAL \
    "$rlgl_h" -o "$rlgl_d"

sedscript=$(echo '
# Import raylib wrapper
/^(extern \(C\))/i import gargula.wrapper.raylib;

# Add "@nogc nothrow" function attributes
/^(extern \(C\))/a @nogc nothrow:

# Remove enum type names, to use them directly from D code
s/enum [^;]*$/enum/
')

sed -i -E "$sedscript" "$rlgl_d"

################################################################
# Physac
################################################################
dstep --package gargula.wrapper \
    --alias-enum-members=true \
    --skip PHYSAC_CALLOC \
    --skip PHYSAC_MALLOC \
    --skip PHYSAC_FREE \
    --skip Vector2 \
    "$physac_h" -o "$physac_d" \
    -- -D PHYSAC_DEFINE_VECTOR2_TYPE

sedscript=$(echo '
# Import raylib wrapper
/^(extern \(C\))/i import gargula.wrapper.raylib;

# Add "@nogc nothrow" function attributes
/^(extern \(C\))/a @nogc nothrow:
')

sed -i -E "$sedscript" "$physac_d"

popd
