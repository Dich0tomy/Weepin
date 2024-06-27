{pkgs, ...}: {
  legacyPackages = {
    tl-optional = pkgs.callPackage ./tl-optional {};
    tl-expected = pkgs.callPackage ./tl-expected {};
  };
}
