{
  self,
  inputs,
  ...
}: {
  imports = [
    inputs.treefmt.flakeModule
  ];

  perSystem = {...}: {
    treefmt = {
      projectRootFile = "${self}/flake.lock";

      programs = {
        deadnix.enable = true;
        alejandra.enable = true;
        clang-format.enable = true;
      };
    };
  };
}
