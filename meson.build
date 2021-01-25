project('raylib-meson', 'c', 'cpp', 'd')

cc = meson.get_compiler('c')
dc = meson.get_compiler('d')

link_args = []
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
foreach opt : get_option('raylib_options')
  split_opt = opt.split('=')
  if split_opt.length() > 1
    raylib_opts.add_cmake_defines({ split_opt[0] : split_opt[1] })
  else
    raylib_opts.add_cmake_defines({ split_opt[0] : 'ON' })
  endif
endforeach
raylib_opts.append_compile_args('c', '-w')
raylib_subproject = cmake.subproject('raylib', options: raylib_opts)
dependencies += raylib_subproject.dependency('raylib')

# D subprojects
betterclist = subproject('betterclist')
bettercmath = subproject('bettercmath')
flyweightbyid = subproject('flyweightbyid')

dependencies += [
  betterclist.get_variable('betterclist_dep'),
  bettercmath.get_variable('bettercmath_dep'),
  flyweightbyid.get_variable('flyweightbyid_dep'),
  dependency('fswatch', version: ['>=0.5.1', '<0.6.0'], method: 'dub'),
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
endif

# Project files
inc_dir = include_directories(
  'source',
)

sources = files(
  'source/gargula/builtin/camera.d',
  'source/gargula/builtin/clearbackground.d',
  'source/gargula/builtin/musicstream.d',
  'source/gargula/builtin/package.d',
  'source/gargula/builtin/shapes.d',
  'source/gargula/builtin/sprite.d',
  'source/gargula/builtin/tween.d',
  'source/gargula/game.d',
  'source/gargula/gamenode.d',
  'source/gargula/hotreload.d',
  'source/gargula/log.d',
  'source/gargula/memory.d',
  'source/gargula/node.d',
  'source/gargula/package.d',
  'source/gargula/resource/audiostream.d',
  'source/gargula/resource/font.d',
  'source/gargula/resource/music.d',
  'source/gargula/resource/package.d',
  'source/gargula/resource/rendertexture.d',
  'source/gargula/resource/sound.d',
  'source/gargula/resource/texture.d',
  'source/gargula/resource/wave.d',
  'source/gargula/savestate.d',
  'source/gargula/wrapper/raylib.d',
)

gargula_dep = declare_dependency(
  sources: sources,
  include_directories: inc_dir,
  link_args: link_args,
  dependencies: dependencies,
)
