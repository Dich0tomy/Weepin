{
  pkgs,
  config,
  lib,
  ...
}: {
  devShells = {
    default = config.devShells.gcc;

    gcc = pkgs.mkShell.override {stdenv = pkgs.gcc14.stdenv;} {
      hardeningDisable = ["all"];

      inputsFrom = builtins.attrValues config.packages;

      packages = [
        pkgs.gcc14
        config.treefmt.build.wrapper
      ];

      env = {
        CLANGD_PATH = lib.getExe' pkgs.clang-tools_18 "clangd";
        ASAN_SYMBOLIZER_PATH = lib.getExe' pkgs.llvmPackages_18.bintools-unwrapped "llvm-symbolizer";
      };
    };
  };
}
