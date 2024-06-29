{
  lib,
  stdenv,
  cmake,
  libdwarf,
  cpptrace,
  zstd,
  fetchFromGitHub,
}:
stdenv.mkDerivation (self: {
  pname = "libassert";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "jeremy-rifkin";
    repo = "libassert";
    rev = "v${self.version}";
    sha256 = "sha256-wc6EvZw0Rbc5NUdsucpZeG5YIoRXqjGoOZomWdEtDOo=";
  };

  cmakeBuildType = "debug";

  cmakeFlags = [
    "-DLIBASSERT_USE_EXTERNAL_CPPTRACE=ON"
  ];

  nativeBuildInputs = [cmake];

  buildInputs = [
    libdwarf
    cpptrace
    (lib.getDev zstd)
  ];

  postInstall = ''
    mkdir -p $out/lib/pkgconfig

    substitute \
    	${./libassert.pc} \
    	$out/lib/pkgconfig/libassert.pc \
    	--subst-var out \
    	--subst-var version
  '';
})
