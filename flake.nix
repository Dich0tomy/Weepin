{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    parts.url = "github:hercules-ci/flake-parts";
    treefmt.url = "github:numtide/treefmt-nix";
  };

  outputs = {parts, ...} @ inputs:
    parts.lib.mkFlake {inherit inputs;} {
      systems = ["aarch64-darwin" "aarch64-linux" "x86_64-darwin" "x86_64-linux"];

      imports = [
        ./nix/treefmt.nix
      ];

      perSystem = {pkgs, ...}: {
        formatter = pkgs.alejandra;

        imports = [
          ./nix/shell
        ];
      };
    };
}
