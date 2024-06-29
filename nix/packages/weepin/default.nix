{
	stdenv,
	self,
	config,
	lib,
	meson,
	ninja,
	pkg-config,
	cmake,
	spdlog,
	fmt,
	just,
	magic-enum,
}:
let
	version = lib.fileContents "${self}/VERSION";
in
stdenv.mkDerivation (this: {
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
	] ++ builtins.attrValues config.legacyPackages; # Bundled libs

	nativeBuildInputs = [
		meson
		cmake
		ninja
		pkg-config
		just
	];
})
