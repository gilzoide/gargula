project('raylib-meson', 'c', 'cpp', 'd')

cc = meson.get_compiler('c')
dc = meson.get_compiler('d')

d_args = []
link_args = []
name_suffix = []
dependencies = []

# Raylib configuration
cmake = import('cmake')
raylib_opts = cmake.subproject_options()
raylib_opts.set_install(false)
raylib_opts.add_cmake_defines({
  'BUILD_EXAMPLES': 'OFF',
  'PLATFORM': meson.get_external_property('raylib_platform', 'Desktop'),
  # Add other CMake options for Raylib, if needed
})
raylib_subproject = cmake.subproject('raylib', options: raylib_opts)
dependencies += raylib_subproject.dependency('raylib_static')

betterclist = subproject('betterclist')
bettercmath = subproject('bettercmath')
flyweightbyid = subproject('flyweightbyid')

dependencies += [
  betterclist.get_variable('betterclist_dep'),
  bettercmath.get_variable('bettercmath_dep'),
  flyweightbyid.get_variable('flyweightbyid_dep'),
]

# General configuration
if host_machine.system() == 'windows'
  dependencies += [
    cc.find_library('winmm'),
  ]
elif host_machine.system() == 'darwin'
  # TODO
elif host_machine.system() == 'linux'
  dependencies += [
    cc.find_library('m'),
    cc.find_library('dl'),
  ]
elif host_machine.system() == 'emscripten'
  link_args += [
    '-s', 'ENVIRONMENT=web',
    '-s', 'USE_GLFW=3',
  ]
  d_args += ['--mtriple=wasm32', '--output-bc']
endif

if dc.get_id() == 'llvm'
  d_args += '-betterC'
endif

# Project files
inc_dir = include_directories(
  'source',
  'libs/d_wrappers',
  'libs/druntime/src',
)

sources = files(
  'source/gargula/run.d',
  #'libs/d_wrappers/raylib.d',
)

gargula_dep = declare_dependency(
  sources: sources,
  include_directories: inc_dir,
  link_args: link_args,
  dependencies: dependencies,
)

executable('empty',
  'source/app.d',
  dependencies: gargula_dep,
  d_args: d_args,
  name_suffix: meson.get_external_property('name_suffix', []),
  link_language: meson.get_external_property('link_language', 'd'),
)
