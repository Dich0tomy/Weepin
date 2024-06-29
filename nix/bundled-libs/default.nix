{
  pkgs,
  lib,
  ...
}: let
  callPackage = lib.callPackageWith (pkgs // legacyPackages);
  legacyPackages = {
    tl-optional = callPackage ./tl-optional {};
    tl-expected = callPackage ./tl-expected {};
    libassert = callPackage ./libassert {};
    libdwarf = callPackage ./libdwarf {};
    cpptrace = callPackage ./cpptrace {};
  };
in {
  inherit legacyPackages;
}
