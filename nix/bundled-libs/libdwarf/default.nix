{
  lib,
  stdenv,
  cmake,
  zlib,
  fetchFromGitHub,
}:
stdenv.mkDerivation (self: {
  pname = "libdwarf";
  version = "0.10.0";

  src = fetchFromGitHub {
    owner = "davea42";
    repo = "libdwarf-code";
    rev = "v${self.version}";
    sha256 = "sha256-NcZ4lYu+UjHz+93JUHn7IdlkXnAzvFNPZIk8lYrpy+w=";
  };

  configureFlags = [
    "--enable-shared"
    "--disable-nonshared"
  ];

  cmakeBuildType = "debug";

  nativeBuildInputs = [cmake];

  buildInputs = [
    (lib.getDev zlib)
  ];
})
