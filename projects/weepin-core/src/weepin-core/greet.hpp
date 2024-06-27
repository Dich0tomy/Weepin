#include <string_view>

#include <fmt/format.h>

namespace weepin
{

auto greet(std::string_view who) -> void
{
	fmt::print("Hello, {}!\n", who);
}

} // namespace weepin
