{
  stdenv,
  self,
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
  version = lib.fileContents "${self}/VERSION";
in
  stdenv.mkDerivation (_this: {
    pname = "weepin";
    version = "${version}+nix";

    strictDeps = true;
    enableParallelBuilding = true;

    dontUseCmakeConfigure = true;

    # TODO: Proper meson configure and shi
    mesonBuildType = "debug";

    src = self;

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
  })
