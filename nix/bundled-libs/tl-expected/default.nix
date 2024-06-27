{
  stdenv,
  cmake,
  fetchFromGitHub,
}:
stdenv.mkDerivation (self: {
  pname = "expected";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "TartanLlama";
    repo = "expected";
    rev = "v${self.version}";
    sha256 = "sha256-AuRU8VI5l7Th9fJ5jIc/6mPm0Vqbbt6rY8QCCNDOU50=";
  };

  strictDeps = true;

  nativeBuildInputs = [cmake];

  postInstall = ''
    mkdir -p $out/lib/pkgconfig

    substitute \
    	${./expected.pc} \
    	$out/lib/pkgconfig/expected.pc \
    	--subst-var out \
    	--subst-var version
  '';
})
