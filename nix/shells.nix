{
  pkgs,
  config,
  lib,
  ...
}: {
  devShells = {
    default = config.devShells.gcc;

    gcc = pkgs.mkShell.override {stdenv = pkgs.gcc14Stdenv;} {
      hardeningDisable = ["all"];

      inputsFrom = builtins.attrValues config.packages;

      packages = [
        config.treefmt.build.wrapper

        # Debugging
        pkgs.gdb
        pkgs.rr

        # Building
        pkgs.ccache
      ];

      env = {
        CLANGD_PATH = lib.getExe' pkgs.clang-tools_18 "clangd";
        ASAN_SYMBOLIZER_PATH = lib.getExe' pkgs.llvmPackages_18.bintools-unwrapped "llvm-symbolizer";
      };
    };
  };
}
