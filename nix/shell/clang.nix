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
  cmake,
  spdlog,
  fmt,
  just,
  magic-enum,
  ...
}:
mkShell.override {stdenv = lowPrio llvmPackages_18.stdenv;} {
	hardeningDisable = ["all"];

  packages =
    [
    	# treefmt
      config.treefmt.build.wrapper

      # essential build tools
      meson
      cmake
      ninja
      pkg-config
      just

      # libs
      spdlog
      fmt
			magic-enum
    ]
    ++ builtins.attrValues config.legacyPackages;

  env = {
    CLANGD_PATH = lib.getExe' clang-tools_18 "clangd";
    ASAN_SYMBOLIZER_PATH = lib.getExe' llvmPackages_18.bintools-unwrapped "llvm-symbolizer";
  };
}
