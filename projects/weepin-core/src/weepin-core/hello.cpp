#include <fmt/format.h>

#include <weepin-core/greet.hpp>

namespace weepin
{

auto hello() -> void
{
	greet("world");
}

} // namespace weepin
