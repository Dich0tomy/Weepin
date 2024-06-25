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

Classic JSON format.

```json
{
  "version": 1,
  "pins": {
    "resource": {
      "url": "https://example.com/resource-0.1.0.tar.gz",
    },
    "resource2": {
      "url": "https://example.com/resource-0.1.0.tar.gz", 
    },
  },
}
```
