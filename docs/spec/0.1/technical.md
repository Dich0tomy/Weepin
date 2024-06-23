<!-- vim-markdown-toc GFM -->

* [Technical spec of weepin](#technical-spec-of-weepin)
* [The `weepin/` directory](#the-weepin-directory)
  * [`default.nix`](#defaultnix)
    * [Structure](#structure)
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

# The `weepin/` directory

It contains the following files:

## `default.nix`

It has to contain a `default.nix` file to be requirable from outside.

The file will return a function that will accept a single attrset with a config. 
For this release there's no config.

The file will contain a loader mechanism which will read `sources.lock` and construct a special structure.

### Structure

This structure is not the content of `sources.json`,
but a generated structure for the user **after** doing `import ./weepin {}`.

These are the abstract kinds and their guaranteed attributes after importing.  
Note that these don't reflect and are not reflect by the `RI`s and they don't reflect the contents of the internal lock file or `weepin.json5`.

`A(B)` means that `A` inherits attributes from `B`.

- `Pinned`:
  - `kind`: `"pinned"|"template"|"channel"|"git"|"github"|"gitlab"` - Kind of the resource
  - `url`: `string` - Fully resolvable (no templates) url of the resource
  - `hash`: `string` - Hash of the resource
  - `outPath` - The result of evaluating a fetcher for the given source

  - `Template(Pinned)`:
    - `extra.template`: `string` - Template for `url`, see [`Template`](#templateri)
    - `extra.attrs`: `table<string, string>` - Used template tags and their values

    - `Channel(Template)`:
      - `extra.attrs.release`: `string` - Specific release.
          This is not e.g., `nixos-unstable`, but `nixos-24.11pre641786.d603719ec6e2`.
          If you want the channel name just use the name of the pin.

    - `Git(Template)`:
      - `extra.attrs.owner`: `string` - Owner name
      - `extra.attrs.name`: `string` - Repository name
      - `extra.attrs.commit`: `string` - Specific commit
      - `extra.attrs.branch`: `string` - Specific branch
      - `extra.attrs.tag`: `string|null` - Set if `extra.repo.commit` belongs to a tag

      - `Gitlab(Git)`:
        - `extra.attrs.group`: `string|null` - Optional group name

An example with all of the kinds above (`hash` and `outPath` omitted for brevity):

```nix
{
  resource = { # Pinned
    kind = "pinned";
    url = "https://example.com/resource-0.1.0.tar.gz";
  };
  resource2 = { # Template with one attr
    kind = "template";
    url = "https://example.com/resource-0.1.0.tar.gz";
    extra = {
      template = "https://example.com/resource-<version>.1.0.tar.gz";
      attrs.version = "0.1.0";
    };
  };
  fooga = { # Template with several attributes
    kind = "template";
    url = "https://example.com/fooga-0.1.0.tar.gz";
    extra = {
      template = "https://example.com/<name>-<version>.1.0.tar.gz";
      attrs = {
        name = "fooga";
        version = "0.1.0";
      };
    };
  };
  nixos-unstable = { # A channel
    kind = "channel";
    url = "https://releases.nixos.org/nixos/unstable/nixos-24.11pre641786.d603719ec6e2/nixexprs.tar.xz";
    extra = {
      template = "https://releases.nixos.org/nixos/unstable/<release>/nixexprs.tar.xz";
      attrs = {
        release = "nixos-24.11pre641786.d603719ec6e2";
      };
    };
  };
  "lua-utils.nvim" = { # A git package
    kind = "git";
    url = "https://api.github.com/repos/nvim-neorg/lua-utils.nvim/tarball/v1.0.2";
    extra = {
      template = "https://api.github.com/repos/<owner>/<name>/tarball/<tag>";
      attrs = {
        owner = "nvim-neorg";
        name = "lua-utils.nvim";
        commit = "e565749421f4bbb5d2e85e37c3cef9d56553d8bd";
        branch = "main";
        tag = "v1.0.2";
      };
    };
  };
  "iswap.nvim" = { # A git package
    kind = "git";
    url = "https://github.com/mizlan/iswap.nvim/archive/e02cc91f2a8feb5c5a595767d208c54b6e3258ec.tar.gz";
    extra = {
      template = "https://github.com/<owner>/<name>/archive/<commit>.tar.gz";
      attrs = {
        owner = "mizlan";
        name = "iswap.nvim";
        commit = "e565749421f4bbb5d2e85e37c3cef9d56553d8bd";
        branch = "master";
        tag = null;
      };
    };
  };
  # Gitlab would be similar as above but with `group` as well and other `url`
}
```

## `sources.lock`

JSON5 format? Or JSON?.

```json5
{
  version: 1,
  pins: {
    resource: {
      url: "https://example.com/resource-0.1.0.tar.gz",
    },
    resource2: { // Template with one attr
      url: "https://example.com/resource-0.1.0.tar.gz", 
    },
  },
}
```
