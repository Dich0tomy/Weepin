{
  stdenv,
  cmake,
  fetchFromGitHub,
}:
stdenv.mkDerivation (self: {
  pname = "optional";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "TartanLlama";
    repo = "optional";
    rev = "v${self.version}";
    sha256 = "sha256-WPTXTQmzJjAIJI1zM6svZZTO8gP/jt5xDHHRCCu9cmI=";
  };

  strictDeps = true;

  nativeBuildInputs = [cmake];

  postInstall = ''
    mkdir -p $out/lib/pkgconfig

    substitute \
    	${./optional.pc} \
    	$out/lib/pkgconfig/optional.pc \
    	--subst-var out \
    	--subst-var version
  '';
})
