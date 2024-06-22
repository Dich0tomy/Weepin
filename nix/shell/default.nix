{
  pkgs,
  config,
  ...
}: let
  clang = pkgs.callPackage ./clang.nix {inherit config;};
  gcc = pkgs.callPackage ./gcc.nix {inherit config;};
in {
  devShells = {
    inherit clang gcc;
  };
}
