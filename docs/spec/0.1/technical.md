# Table of Contents

<!-- vim-markdown-toc GFM -->

* [Technical spec of weepin](#technical-spec-of-weepin)
* [The weepin store](#the-weepin-store)
  * [`default.nix`](#defaultnix)
  * [`sources.lock`](#sourceslock)

<!-- vim-markdown-toc -->

# Technical spec of weepin

> [!NOTE]
> This is a **pre implementation** draft, which means it's *just* an idea and no code yet.
> It may change if I see some technical limitations (like slow nix evals).

- **Supported platforms**:
  - `aarch64-darwin`
  - `aarch64-linux`
  - `x86_64-darwin`
  - `x86_64-linux`
- **Build**: Meson & Nix
- **Language**: C++23 - [FAQ - 2. Why C++?](../../faq.md#2-why-c)
- **Compiler**:
  - Default: g++
  - Other: clang++
- **Linker**:
  - Default: mold
- **Used libs**:
  - `fmt` - formatting library
  - `magic-enum` - Nice library for reflecting on enums
  - `optional` - TartanLLama's optional library
  - `expected` - TartanLLama's optional library

# The weepin store

See - [The weepin store](./functional.md#the-weepin-store)

It contains the following files:

## `default.nix`

It has to contain a `default.nix` file to be requirable from outside.

The file will return a function that will accept a single attrset with a config.  
For this release there's no config.

The file will contain a loader mechanism which will read `sources.lock` and construct a special structure.

## `sources.lock`

<!-- TODO: Fill this out -->

JSON format.
It's best to make this file look as close to the generated structure as possible to reduce
overhead.

Notes:
- The generated structure for `Channel` contains attr `name` - we don't store in the lock file,
  because it's easily inferrable form the URL.

- The generated structure for `Git` contains attrs `group`, `owner` and `name` - we don't store in the lock file,
  because it's easily inferrable form the URL.
  <!-- TODO: Think about branches, commits and tags here -->
  <!-- TODO: Benchmark loading perf for large files, with locked attrs and with inferred ones -->

```json
{
  "version": 1,
  "pins": {
    "pinned resource": {
      "url": "https://example.com/resource-0.1.0.tar.gz",
      "hash": "sha256---------------------------------"
    },
    "template resource": {
      "url": "https://example.com/resource-0.1.0.tar.gz",
      "template": "https://example.com/resource-<version>.tar.gz",
      "attrs": {
        "version": "0.1.0"
      }
    },
    "channel resource": {
      "url": "https://releases.nixos.org/nixos/unstable/nixos-24.11pre644565.b2852eb9365c/nixexprs.tar.xz",
      "template": "https://releases.nixos.org/nixos/unstable/nixos-<release>/nixexprs.tar.xz",
      "attrs": {
        "release": "24.11pre644565.b2852eb9365c"
      }
    },
    "git channel": {
      "url": "https://github.com/cachix/pre-commit-hooks.nix/archive/cc4d466cb1254af050ff7bdf47f6d404a7c646d1.tar.gz",
      "attrs": {
        "branch": "main",
        "commit": "................"
      }
    }
  }
}
```
