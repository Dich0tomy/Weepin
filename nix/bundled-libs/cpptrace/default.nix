{
  lib,
  stdenv,
  cmake,
  libdwarf,
  zlib,
  zstd,
  fetchFromGitHub,
  writeText,
}:
stdenv.mkDerivation (self: {
  pname = "cpptrace";
  version = "0.6.2";

  static = true;

  src = fetchFromGitHub {
    owner = "jeremy-rifkin";
    repo = "cpptrace";
    rev = "v${self.version}";
    sha256 = "sha256-zjPxPtq+OQ104sJoeBD3jpMV9gV57FSHEJS4W6SF8GM=";
  };

  cmakeBuildType = "debug";

  cmakeFlags =
    [
      "-DCPPTRACE_USE_EXTERNAL_LIBDWARF=1"
      "-DCPPTRACE_USE_EXTERNAL_ZSTD=1"
    ]
    ++ lib.optional (!self.static) "-DDCPPTRACE_BUILD_SHARED=1";

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    (lib.getDev zstd)
    (lib.getDev zlib)
    libdwarf
  ];

  propagatedBuildInputs = [] ++ lib.optional self.static libdwarf;

  postInstall = let
    cpptrace-pc-content = builtins.readFile ./cpptrace.pc;
    cpptrace-pc =
      writeText
      "cpptrace.pc"
      (
        if self.static
        then (builtins.replaceStrings ["-lcpptrace"] ["-lcpptrace -ldwarf"] cpptrace-pc-content)
        else cpptrace-pc-content
      );
  in ''
    install -Dm 644 ${cpptrace-pc} $out/lib/pkgconfig/cpptrace.pc
  '';
})
