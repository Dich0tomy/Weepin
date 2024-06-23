sources = files(
  'src/main.cpp'
)

include_directories = include_directories(
  'src'
)

local_deps = [
  dependency('fmt')
  dependency('optional')
  dependency('expected')
  dependency('magic-enum')
]

executable(
  'weepin',
  sources,
  include_directories: include_directories,
  dependencies: [ _dire_test_internal, local_deps ]
)
