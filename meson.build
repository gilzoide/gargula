project('raylib-meson', 'c', 'cpp', 'd')

cc = meson.get_compiler('c')
dc = meson.get_compiler('d')

c_args = []
compile_args = []
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

# Chipmunk configuration
chipmunk_opts = cmake.subproject_options()
chipmunk_opts.set_install(false)
chipmunk_opts.add_cmake_defines({
  'BUILD_DEMOS': 'OFF',
  'BUILD_SHARED': 'OFF',
  'BUILD_STATIC': 'ON',
  'FORCE_CLANG_BLOCKS': 'OFF',
})
chipmunk_opts.append_compile_args('c', '-w')
chipmunk_subproject = cmake.subproject('Chipmunk2D', options: chipmunk_opts)
dependencies += chipmunk_subproject.dependency('chipmunk_static')

# D subprojects
betterclist = subproject('betterclist')
bettercmath = subproject('bettercmath')
flyweightbyid = subproject('flyweightbyid')
chipmunkd = declare_dependency(
  sources: files(
    'subprojects/chipmunkd/src/chipmunk/chipmunk.d',
    'subprojects/chipmunkd/src/chipmunk/chipmunk_private.d',
    'subprojects/chipmunkd/src/chipmunk/chipmunk_structs.d',
    'subprojects/chipmunkd/src/chipmunk/chipmunk_types.d',
    'subprojects/chipmunkd/src/chipmunk/chipmunk_unsafe.d',
    'subprojects/chipmunkd/src/chipmunk/cpArbiter.d',
    'subprojects/chipmunkd/src/chipmunk/cpBB.d',
    'subprojects/chipmunkd/src/chipmunk/cpBody.d',
    'subprojects/chipmunkd/src/chipmunk/cpConstraint.d',
    'subprojects/chipmunkd/src/chipmunk/cpDampedRotarySpring.d',
    'subprojects/chipmunkd/src/chipmunk/cpDampedSpring.d',
    'subprojects/chipmunkd/src/chipmunk/cpGearJoint.d',
    'subprojects/chipmunkd/src/chipmunk/cpGrooveJoint.d',
    'subprojects/chipmunkd/src/chipmunk/cpHastySpace.d',
    'subprojects/chipmunkd/src/chipmunk/cpMarch.d',
    'subprojects/chipmunkd/src/chipmunk/cpPinJoint.d',
    'subprojects/chipmunkd/src/chipmunk/cpPivotJoint.d',
    'subprojects/chipmunkd/src/chipmunk/cpPolyline.d',
    'subprojects/chipmunkd/src/chipmunk/cpPolyShape.d',
    'subprojects/chipmunkd/src/chipmunk/cpRatchetJoint.d',
    'subprojects/chipmunkd/src/chipmunk/cpRobust.d',
    'subprojects/chipmunkd/src/chipmunk/cpRotaryLimitJoint.d',
    'subprojects/chipmunkd/src/chipmunk/cpShape.d',
    'subprojects/chipmunkd/src/chipmunk/cpSimpleMotor.d',
    'subprojects/chipmunkd/src/chipmunk/cpSlideJoint.d',
    'subprojects/chipmunkd/src/chipmunk/cpSpace.d',
    'subprojects/chipmunkd/src/chipmunk/cpSpatialIndex.d',
    'subprojects/chipmunkd/src/chipmunk/cpTransform.d',
    'subprojects/chipmunkd/src/chipmunk/cpVect.d',
    'subprojects/chipmunkd/src/chipmunk/package.d',
  ),
  include_directories: 'subprojects/chipmunkd/src',
)

dependencies += [
  betterclist.get_variable('betterclist_dep'),
  bettercmath.get_variable('bettercmath_dep'),
  flyweightbyid.get_variable('flyweightbyid_dep'),
  chipmunkd,
]

# DUB dependency
if get_option('debug') and host_machine.system() != 'emscripten'
  fswatch = dependency('fswatch', version: ['>=0.5.1', '<0.6.0'], required: false, method: 'dub')
  dependencies += fswatch
  if not fswatch.found()
    warning('fswatch not found, hot reloading not supported')
  endif
endif

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
  compile_args += '--betterC'
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
  'source/gargula/chipmunk/body.d',
  'source/gargula/chipmunk/debugdraw.d',
  'source/gargula/chipmunk/package.d',
  'source/gargula/chipmunk/shape.d',
  'source/gargula/chipmunk/space.d',
  'source/gargula/game.d',
  'source/gargula/gamenode.d',
  'source/gargula/hotreload.d',
  'source/gargula/log.d',
  'source/gargula/main.d',
  'source/gargula/memory.d',
  'source/gargula/node.d',
  'source/gargula/package.d',
  'source/gargula/resource/audiostream.d',
  'source/gargula/resource/font.d',
  'source/gargula/resource/music.d',
  'source/gargula/resource/package.d',
  'source/gargula/resource/rendertexture.d',
  'source/gargula/resource/shader.d',
  'source/gargula/resource/sound.d',
  'source/gargula/resource/texture.d',
  'source/gargula/resource/wave.d',
  'source/gargula/savestate.d',
  'source/gargula/wrapper/physac.d',
  'source/gargula/wrapper/raylib.d',
  'source/gargula/wrapper/raymath.d',
  'source/gargula/wrapper/rlgl.d',
)

physac = static_library('physac',
  'source/physac_impl.c',
  c_args: c_args,
  include_directories: raylib_subproject.include_directories('raylib'),
)

gargula_dep = declare_dependency(
  sources: sources,
  include_directories: inc_dir,
  link_with: physac,
  compile_args: compile_args,
  link_args: link_args,
  dependencies: dependencies,
)
