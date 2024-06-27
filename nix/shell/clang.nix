{
  lib,
  config,
  lowPrio,
  mkShell,
  llvmPackages_18,
  clang-tools_18,
  meson,
  ninja,
  pkg-config,
  mold,
  cmake,
  spdlog,
  fmt,
  ...
}:
mkShell.override {stdenv = lowPrio llvmPackages_18.stdenv;} {
  packages =
    [
      config.treefmt.build.wrapper
      meson
      cmake
      ninja
      pkg-config

      # libs
      spdlog
      fmt
    ]
    ++ builtins.attrValues config.legacyPackages;

  env = {
    CXX_LD = lib.getExe mold;
    CLANGD_PATH = lib.getExe' clang-tools_18 "clangd";
    ASAN_SYMBOLIZER_PATH = lib.getExe' llvmPackages_18.bintools-unwrapped "llvm-symbolizer";
  };
}
