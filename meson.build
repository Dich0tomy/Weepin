# NOTE:
# This project is expected to be built under a Nix environment.
# No guarantees are made about the standalone capabilities of this
# build under non-Nix environments.
project(
  'weepin', 'cpp',
  version : files('./VERSION'),
  meson_version : '>= 0.63.0',
  license: 'EUPL-1.1',

  default_options:  [
    'cpp_std=c++23'
  ]
)

if(get_option('debug') and meson.get_compiler('cpp').get_id() == 'clang')
  add_project_arguments(
    '-DLIBCXX_ENABLE_DEBUG_MODE=1',
    '-D_LIBCPP_DEBUG=1',
    '-D_LIBCPP_ABI_BOUNDED_ITERATORS=1',
    '-D_LIBCPP_HARDENING_MODE=_LIBCPP_HARDENING_MODE_DEBUG',
    language: 'cpp'
  )
endif

if(get_option('debug') and meson.get_compiler('cpp').get_id() == 'gcc')
  add_project_arguments(
    '-D_GLIBCXX_DEBUG_PICKY',
    '-D_GLIBCXX_DEBUG_BACKTRACE',
    language: 'cpp'
  )
endif

subdir('projects')
