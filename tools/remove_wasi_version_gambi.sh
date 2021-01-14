#!/bin/sh

script_root=$(dirname $(realpath $0))
project_root="$script_root/.."

core_file="$project_root/libs/druntime/src/core/sys/wasi/core.d"
config_file="$project_root/libs/druntime/src/core/sys/wasi/config.d"
types_file="$project_root/libs/druntime/src/core/sys/wasi/sys/types.d"

lua_script='print((string.gsub(io.read("*a"), "version[^:]+:", "")))'
echo "$(cat $core_file | lua -e "$lua_script")" > $core_file
echo "$(cat $config_file | lua -e "$lua_script")" > $config_file
echo "$(cat $types_file | lua -e "$lua_script")" > $types_file

