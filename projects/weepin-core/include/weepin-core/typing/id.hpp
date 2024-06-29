namespace weepin
{

constexpr auto id(auto&& arg) -> decltype(auto)
{
	return static_cast<decltype(arg)&&>(arg);
}

} // namespace weepin
