sources = files(
  'src/main.cpp'
)

include_directories = include_directories(
  'src'
)

local_deps = [
  dependency('fmt')
]

executable(
  'wee',
  sources,
  include_directories: include_directories,
  dependencies: [ _dire_test_internal, local_deps ]
)
