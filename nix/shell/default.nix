{
  pkgs,
  config,
  ...
}: let
  clang = pkgs.callPackage ./clang.nix {inherit config;};
in {
  devShells = {
    inherit clang;
    default = clang;
  };
}
