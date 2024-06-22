{
  config,
  mkShell,
  meson,
  ninja,
  pkg-config,
  ...
}:
mkShell {
  packages = [
    config.treefmt.build.wrapper
    meson
    ninja
    pkg-config
  ];
}
