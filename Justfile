debug_build_dir := "build_debug"

default:
	@just --list

configure-linux:
	meson configure --buildtype debug --debug -Db_lundef=false -Db_sanitize=address,undefined --warnlevel 3 {{ debug_build_dir }}
alias sd := setup-debug
setup-debug: && configure-linux
	meson setup {{ debug_build_dir }}

alias cd := compile-debug
compile-debug:
	meson compile -C {{ debug_build_dir }} weepin

# vim: ft=make
