{
  stdenv,
  lib,
  meson,
  ninja,
  pkg-config,
  cmake,
  spdlog,
  fmt,
  just,
  magic-enum,
  tl-optional,
  tl-expected,
  libassert,
  cpptrace,
}: let
  self = ./../../../.;
  version = lib.fileContents "${self}/VERSION";
in
  stdenv.mkDerivation {
    pname = "weepin";
    version = "${version}+nix";

    strictDeps = true;
    enableParallelBuilding = true;

    dontUseCmakeConfigure = true;

    # TODO: Proper meson configure and shi
    mesonBuildType = "debug";

    src = lib.fileset.toSource {
      root = self;
      fileset = lib.fileset.unions [
        (self + /projects)
        (self + /VERSION)
        (self + /meson.build)
        (self + /meson_options.txt)
      ];
    };

    buildInputs = [
      magic-enum
      spdlog
      fmt
      tl-optional
      tl-expected
      libassert
      cpptrace
    ];

    nativeBuildInputs = [
      meson
      cmake
      ninja
      pkg-config
      just
    ];
  }
