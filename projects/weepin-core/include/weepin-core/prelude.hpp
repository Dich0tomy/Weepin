// Ideally this would be PCH but meson no likey
#pragma once

#include <utility>
#include <cstdint>
#include <string>
#include <vector>

#include <tl/expected.hpp>
#include <tl/optional.hpp>

#include <libassert/assert.hpp>

#include <weepin-core/typing/lift.hpp>
#include <weepin-core/typing/id.hpp>

/// Stops the application, and signals that a certain path is not implemented.
[[noreturn]] inline auto unimplemented() noexcept -> void
{
	ASSERT(false, "Unimplemented."); // NOLINT
	std::unreachable();
}

namespace detail
{

template<typename Type, auto Distinct>
class DistinctType
{
public:
	constexpr explicit DistinctType() = default;

	template<typename T>
		requires(not std::same_as<T, DistinctType>)
	constexpr explicit DistinctType(T&& data) // NOLINT
		: data(static_cast<T&&>(data))
	{}

	constexpr explicit operator decltype(auto)() & noexcept { return data; }

	constexpr explicit operator decltype(auto)() && noexcept { return std::move(data); }

	constexpr explicit operator decltype(auto)() const& noexcept { return data; }

	constexpr explicit operator decltype(auto)() const&& noexcept { return std::move(data); }

private:
	Type data;
};

} // namespace detail

// NOLINTBEGIN(cppcoreguidelines-macro-usage)
#define BLANKET_TRAP(...) (DEBUG_ASSERT_VAL(false, "This should never happen.\n" #__VA_ARGS__), unreachable())
#define DISTINCT(Type) ::detail::DistinctType<Type, [] {}>
// NOLINTEND(cppcoreguidelines-macro-usage)

using u8 = std::uint8_t;
using i8 = std::int8_t;

using u32 = std::uint32_t;
using i32 = std::int32_t;

using u64 = std::uint64_t;
using i64 = std::int64_t;

using usize = std::size_t;

using f32 = float;
static_assert(sizeof(float) == 4);

using f64 = double;
static_assert(sizeof(double) == 8);

template<typename T>
using Vec = std::vector<T>;

using String = std::string;

using StringView = std::string_view;

template<typename T>
using Optional = tl::optional<T>;

template<typename T, typename E>
using Result = tl::expected<T, E>;

inline constexpr auto Err = WEEPIN_LIFT(::tl::make_unexpected);
inline constexpr auto Ok = WEEPIN_LIFT(::weepin::id);
