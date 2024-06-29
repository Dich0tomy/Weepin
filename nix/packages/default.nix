{self, ...}: {
  perSystem = {
    pkgs,
    config,
    ...
  }: {
    packages = let
      weepin = pkgs.callPackage ./weepin {inherit self config;};
    in {
      weepin-gcc14 = (weepin.override {stdenv = pkgs.gcc14.stdenv;}).overrideAttrs (old: {
        nativeBuildInputs = old.nativeBuildInputs ++ [pkgs.gcc14];
      });
      weepin-clang18 = weepin.override {stdenv = pkgs.lowPrio pkgs.llvmPackages_18.stdenv;};

      default = config.packages.weepin-gcc14; # Arbitrary
    };
  };
}
