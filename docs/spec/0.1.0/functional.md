# Functional spec of weepin

Weepin is an application for pinning nix sources interactively and declaratively.

I wasn't 100% happy with both npins and niv so I made this.

The name of the project is `weepin`, but the name of the main executable is called
`wee`.

The main entrypoint of weepin is `weepin.toml` which contains wee sources.
They *can* but *don't have to* contain version informations at this point.
Sources can either be added with `wee add ...` or added to the file directly.

Weepin will generate a `weepin/` directory which will be imported.
Directory instead of a file to reserve the right to add more things to it in further versions.

```nix
pinned = import ./weepin;
```

# Cli interface

## Conventions

- `foo...` one or more of foo

- `(foo bar)` group of things, typically used together with `...`

- `[foo]` optional group

- `[foo]...` optional group of things

- `[, ...]` denotes more optional items of the same kind as before

- `(foo | bar)` foo or bar, exclusive

## Definitions

Each of the ones before is generally referred to as `WeeURI`

## Pin

Pin loosely refers to a dependency pinned to a specific revision, version, url, etc.
Also refers to specific items in the [`weepin.toml` file](#weepintoml-structure).

## Dirty pin

An item in [`weepin.toml` file](#weepintoml-structure) that doesn't have a version set.

[`wee pin-dirty`](# `wee pin-dirty`) is used to pin such.

### `GitURI`
Pints to a git resource like github, gitlab, sourcehut or a generic one.

All `GitURI`s are implicitly `TemplateURI`s of a form similar to `https://host.com/owner/repo/<rev>`
(dependent on the service) inside, to easily substitute branche, revision, etc.

`GitURI`s have several forms:
- GitHub - `[github:]owner/repo`
<!-- TODO: Think through if I should add group/owner/repo as an alias for gitlab:group/owner/repo -->
- GitLab - `gitlab:[group/]owner/repo` or `https://gitlab.example.com[/group]/owner/repo`
- Sourcehut `srht:owner/repo` or
- Generic git `git:owner/repo` or `git:https://example.com/owner/repo` (e.g. for codeberg, gitea, etc.)

### `TemplateURI`
Contains template tags. Template tags get expanded from tagibutes passed on the commandline.
A template tag is of form `<name>` or `<name1|name2[,|...]>`,

These are later expanded when `wee add`ing by passing `--replace [<name>=]<val>`.

The template tag can alternatively be of form `<name=init>`, `<name=init|name2=init[,|...]>`,
see **`Resolvable template tags and URIs`** below for more information.

To specify a full URL you specify a `TemplateURI`, basically a URI with a template tag inside, like so:
- `http://example.com/archive/<version>.zip`
(or a [`PinnedURI`](#pinneduri))

### `ChannelURI`
`ChannelURIs` match the `^\w*?-\d{2}\.\d{2}(?:\w*?)?$` regex and resolve to nixos channel exprs:
\[\<release> is determined at runtime]
- `nixos-23.11` -> `https://releases.nixos.org/nixos/23.11/<release>/nixexprs.tar.xz` 
- `nixos-unstable` -> `https://releases.nixos.org/nixos/unstable/<release>/nixexprs.tar.xz`
- `nixos-24.05-darwin` -> `https://releases.nixos.org/nixos/24.05-darwin/<release>/nixexprs.tar.xz`
- `nixpkgs-23.05` -> `https://releases.nixos.org/nixpkgs/23.05/<release>/nixexprs.tar.xz`
- etc.

### `PinnedURI`
A `PinnedURI` is a URI that *already* has all the information for pinning in it,
e.g. `https://example.com/archive/0.1.2.zip`

These can't be `wee update`d, because no information about version substitution is available.
If you want to have that possibility, create a TemplateURI instead, e.g. `https://example.com/archive/<version>.zip`

### Resolvable template tags and URIs
A normal template tag only defines the template name - `<name>`,
but it can also optionally define a value its initialized with - `<name=init>`.

`ResolvableURI`s are URIs that contain all the information to resolve them in them.
`ChannelURI`s and `PinnedURI`s are already `ResolvableURI`s.

A `TemplateURI` can be resolvable if it contains a resolvable template tag,
e.g. `https://github.com/owner/repo/tree/<rev:0.1.0>`.

A `GitURI` can be resolvable if it's suffixed with `=init`, e.g.:
- `owner/repo=0.1.0` github with tag
- `gitlab:owner/repo=dev` gitlab with branch
- `git:https://codeberg.com/Codeberg/org=975ee655a3f19fc0554f2a3186d86c5f4a1abe7c` a resolvable `GitURI` for generic git source with an attached commit

Resolvable URIs are provided for convenience when `wee init`ing or `wee add`ing,
instead of:
```shell
$ wee init
$ wee add owner/repo -r 0.1.0
$ wee add repo/baz -r dev

```
It can become
```shell
$ wee init
$ wee add owner/repo=0.1.0 repo/baz=dev
```
And even
```shell
$ wee init owner/repo=0.1.0 repo/baz=dev
```

> [!IMPORTANT]
> `ResolvableURI`s are not `PinnedURI`s!
> `PinnedURI`s are a special kind of URIs that are permanently pinned and cannot be upgraded
> A resolvable `GitURI` or `TemplateURI` is still of its own kind, but it just uses different syntax
> upon `wee add`ing and `wee init`ing which gives it an initial value.

## `wee`
  - `-v, --version` Prints version
  - `-h, --help` Prints help

  Defaults to `wee -h`

## `wee add` ((\<WeeURI> | \<ResolvableURI>) \[POSITIONAL OPTIONS])...
Positional, after each `WeeURI` / `ResolvableURI`:
- `-n, --name <name>` Gives the pin a custom name.
  The name can use template tags.
  `GitURIs` names are derived from repo name,
  `ChannelURI`s names are derived from the channel name.
  `TemplateURI` and `PinnedURI` names are derived from the last path element without extension.
- `-V, --no-validate` Disable validating if the given resource is reachable on the network before adding.
- `-i, --interactive` Invalid for `ResolvableURI`s.
  Weepin will try to determine available versions for a given resource and prompt to pick.
- `-r, --replace [<name>=]<val>` Invalid for `ResolvableURI`s.
  Substitutes given tag `<name>` with `<val>`. `name` is optional if there's only one template tag in the `TemplateURI`.
- `-d, --depends <name>...` Defines a dependency of resource on other resource names.

Adds a specific resource to `weepin.toml` (or `<file>`).

For git URIs it adds the newest available tag or commit by default,
unless `-r, --replace` is passed (it accepts commits, tags and branches).

Since `GitURI`s are implicit `TemplateURI`s `-r` works, you can think of it as `--revision` if that helps ;).

It can be also launched with the `-i, --interactive` flag to pick the revision.

`-i` will fail for `ChannelURI`s, `PinnedURI`s and `TemplateURI`s.

> [!IMPORTANT]
> This action creates the `weepin/` sources.

### Examples

```shell
$ wee add owner/repo=0.1.0
$ wee add owner/repo=0.1.0 -n myrepo owner/repo2 -d myrepo
$ wee add owner/repo=0.1.0 -Vn myrepo https://example.com/<ver>.com -t 0.1.1
$ wee add https://gitlab.company.com/group/owner/repo=f0784ec
$ wee add git:https://gitea.foo.com/owner/repo -ri develop
$ wee add https://example.com/<ver>.tar.xz -t 0.1.1 # We can omit the name because there's only one `ver`
$ wee add https://example.com/<name>/<ver>.tar.xz -t ver=0.1.1 -t name=foo
```

## `wee init` \[OPTIONS] \[(\<WeeURI > | \<ResolvableURI>) \[POSITIONAL OPTIONS]]...
Positional, after each `WeeURI` / `ResolvableURI`:
- `-n, --name <name>` Gives the pin a custom name.
  The name can use template tags.
  `GitURIs` names are derived from repo name,
  `ChannelURI`s names are derived from the channel name.
  `TemplateURI` and `PinnedURI` names are derived from the last path element without extension.
- `-V, --no-validate` Disable validating if the given resource is reachable on the network before adding.
- `-i, --interactive` Invalid for `ResolvableURI`s.
  Weepin will try to determine available versions for a given resource and prompt to pick.
- `-r, --replace [<name>=]<val>` Invalid for `ResolvableURI`s.
  Substitutes given tag `<name>` with `<val>`. `name` is optional if there's only one template tag in the `TemplateURI`.

Initializes `weepin/` (or `<dir>`) and `weepin.toml` (or `<file>`).

Subsequent invocations will overwrite `weepin/` (or `<dir>`) and `weepin.toml` (or `<file>`).

Unlike `npins` and `niv` doesn't track anything by default,
if you want to init with e.g. `nixos-unstable` do `wee init nixos-unstable`.

> [!IMPORTANT]
> This action creates the `weepin/` sources.

### Examples

Same as `wee add` + the `-d` option
```shell
$ wee init owner/repo=0.1.0 owner/repo2=0.1.1
$ wee init https://gitlab.company.com/group/owner/repo/<ver> -t f0784ec -d pins
```

## `wee pin-dirty` \[OPTIONS] 
Options:
- `-i, --interactive` Invalid for `ResolvableURI`s.
- `-g, --generate` Regenerate the `weepin/` sources.

Weepin will try to determine available versions for a given resource and prompt to pick.
Parses the `weepin.toml` file and looks for [dirty pins](#dirty-pin), modifies the file in place
with pinned dependencies.

### Examples

Same as `wee add` + the `-d` option
```shell
$ wee init owner/repo=0.1.0 owner/repo2=0.1.1
$ wee init https://gitlab.company.com/group/owner/repo/<ver> -t f0784ec -d pins
```

## `wee show` \[OPTIONS] \[<name> \[POSITIONAL OPTIONS]]...
Positional options, after each `<name>`
- `-a, --attrs=attrs...` Picks certain attributes, see [`weepin.toml` structure](#weepintoml-structure) for reference.

Options:
- `-f, --format pretty|json|toml` Format to use

Shows all pins matching given `name`s or all if nothing else provided.
Names can use the `*` glob.

### Examples

```shell
$ wee show neovim -a=name,rev -f json
$ wee show
$ wee show neovim nvim-luapad neogit
```
## `wee remove` <name>

Removes a given pin.
Accepts `*` glob.

> [!IMPORTANT]
> This action modifies the generated `weepin/` sources.

### Examples

```shell
$ wee remove nixos-unstable
$ wee remove foo
$ wee remove nvim-*
```

## `wee clear`
Removes all pins from `weepin.toml` or `<file>`.

> [!IMPORTANT]
> This action modifies the generated `weepin/` sources.

### Examples

## `wee repin` [<name> \[POSITIONAL ARGUMENTS]]...
Positional arguments:
- `-r, --replace [<name>=]<val>` Invalid for `ResolvableURI`s.
  Substitutes given tag `<name>` with `<val>`. `name` is optional if there's only one template tag in the `TemplateURI`.

> [!IMPORTANT]
> This action modifies the generated `weepin/` sources.

Without any arguments updates all pins.

With name arguments updates given pins.

With positional `-r` changes given parameters of a pin, typically version.

### Examples

```shell
$ wee repin # Updates everything
$ wee repin neovim -t v0.9.5 # Rollback to 0.9.5
```

# `weepin.toml` structure

```toml
[neovim]
ref = 'github:neovim/neovim'
tag = ''
```

<!-- TODO: This -->

# `weepin/`

No assumptions about that directory should be made other than the fact that the directory is importable from Nix.
This is to allow changes to the structure and files inside for future versions.

You can be sure to receive the following structure when importing:
```nix
{
  name = {
  },
  
}
```

<!-- TODO: This -->

# Non-goals for this release
- Importing
  This release won't support importing sources from niv/npins or `flake.lock`.

- Backwards compatible `weepin/`?
  In stable?
  Operations on the `weepin/` directory which would upgrade
  the framework.
  - `migrate` Migrates to new format, saves info about previous version
    - `-c, --check` Run `nix flake check` after runnnig `migrate`
  - `restore` Restores format to the previous one


- Interactive `TemplateURIs`
  For `TemplateURIs` that don't match channel or template URIs `-i` will try to ask what files are available
  via the given protocol.

  Supported protocols are `ssh`, `http`, `https` and `ftp`.

- Searching/showing based on types, owners and such?

- -D and -W options?

- Rolling back, enforcing tracking by git?

