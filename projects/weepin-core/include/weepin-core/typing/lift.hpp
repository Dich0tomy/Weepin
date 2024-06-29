#pragma once

#define WEEPIN_LIFT_FWD(...) (static_cast<decltype(__VA_ARGS__)&&>(__VA_ARGS__))

#define WEEPIN_LIFT(...) \
	[](auto&&... args) noexcept(noexcept(__VA_ARGS__(WEEPIN_LIFT_FWD(args)...))) \
		-> decltype(__VA_ARGS__(WEEPIN_LIFT_FWD(args)...)) { return __VA_ARGS__(WEEPIN_LIFT_FWD(args)...); }
