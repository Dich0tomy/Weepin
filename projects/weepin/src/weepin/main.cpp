#include <weepin-core/prelude.hpp>
#include <weepin-core/hello.hpp>

auto main() -> int
{
	weepin::hello();
	UNREACHABLE("If you see this that means weepin works :)");
}
