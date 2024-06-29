sources = files(
  'src/weepin/main.cpp'
)

include_directories = include_directories('src')

executable(
  'weepin',
  sources,
  include_directories: include_directories,
  dependencies: [ weepin_core ],
  install: true
)
