{
  config,
  lowPrio,
  mkShell,
  llvmPackages_18,
  meson,
  ninja,
  pkg-config,
  ...
}:
mkShell.override {stdenv = lowPrio llvmPackages_18.stdenv;} {
  packages = [
    config.treefmt.build.wrapper
    meson
    ninja
    pkg-config
  ];
}
