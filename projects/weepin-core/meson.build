sources = files(
	'src/weepin-core/hello.cpp'
)

compilation_options = [
  'cpp_std=c++20'
]

local_deps = [
  # System
  dependency('threads'),

  # Bundled
  dependency('fmt'),
  dependency('spdlog'),
  dependency('optional'),
  dependency('expected'),
  dependency('magic_enum'),
]

public_include_dirs = include_directories('include')
private_include_dirs = include_directories('src')

_weepin_core = static_library(
	'weepin-core',
	sources: sources,
  dependencies: local_deps,
	include_directories: [ public_include_dirs, private_include_dirs ],
	override_options: compilation_options,
  # install: true # TODO: Figure out what this does
)

weepin_core = declare_dependency(
	link_with: _weepin_core,
	include_directories: public_include_dirs,
  dependencies: local_deps
)
