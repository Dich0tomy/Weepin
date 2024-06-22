# Functional spec of weepin

Weepin is an application for pinning nix sources interactively and declaratively.

I wasn't 100% happy with both npins and niv so I made this.

The name of the project is `weepin`, but the name of the main executable is called
`wee`.

The main entrypoint of weepin is `weepin.toml` which contains weepin sources.  
They *can* but *don't have to* contain version informations at this point.  
Sources can either be added with `weepin add ...` or added to the file directly.

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

Each of the ones before is generally referred to as `WeepinRI` (Weepin Resource Identifier).

### Pin

Pin loosely refers to a dependency pinned to a specific revision, version, url, etc.  
Also refers to specific items in the [`weepin.toml` file](#weepintoml-structure).

### Dirty pin

An item in [`weepin.toml` file](#weepintoml-structure) that doesn't have a version set.

[`weepin pin-dirty`](#wee-pin-dirty-options-options) is used to pin such.

### Template tag

A template tag a special substring of form `<name>` or `<name=init>` which is later expanded with a specific value.

The latter is a special type of a template tag called a `resorvable template tag`.  
See [Resolvable template tags and RIs](#resolvable-template-tags-and-ris) below for more information on that.

### `GitRI`
Pints to a git resource like github, gitlab, sourcehut or a generic one.

All `GitRI`s are implicitly `TemplateRI`s of a form similar to `https://host.com/owner/repo/<rev>`
(dependent on the service) inside, to easily substitute branche, revision, etc.

<!-- TODO: Think through if I should add group/owner/repo as an alias for gitlab:group/owner/repo -->

`GitRI`s have several forms:
- GitHub - `owner/repo` or `github:owner/repo` or `gh:owner/repo`
- GitLab - `gl:[group/]owner/repo` or `gitlab:[group/]owner/repo` or `https://gitlab.example.com[/group]/owner/repo`
- Sourcehut - `srht:owner/repo`
- Generic git - `git:owner/repo` or `git:https://example.com/owner/repo` (e.g. for codeberg, gitea, etc.)

> [!NOTE]
> These are not *neccesarilly* reflected in the internal lockfile or `weepin.toml`.

### `TemplateRI`
Contains template tags. Template tags get expanded from attributes passed on the commandline.  
A template tag is of form `<name>` or `<name1|name2[,|...]>`,

These are later expanded when `weepin add`ing by passing `--replace [<name>=]<val>`.

The template tag can alternatively be of form `<name=init>`, `<name=init|name2=init[,|...]>`,
see [Resolvable template tags and RIs](#resolvable-template-tags-and-ris) below for more information.

To specify a full URL you specify a `TemplateRI`, basically a RI with a template tag inside, like so:
- `http://example.com/archive/<version>.zip`
(or a [`PinnedRI`](#pinnedri))

### `ChannelRI`
`ChannelRIs` match the `^\w*?-\d{2}\.\d{2}(?:\w*?)?$` regex and resolve to nixos channel exprs:
\[\<release> is determined at runtime]
- `nixos-23.11` -> `https://releases.nixos.org/nixos/23.11/<release>/nixexprs.tar.xz` 
- `nixos-unstable` -> `https://releases.nixos.org/nixos/unstable/<release>/nixexprs.tar.xz`
- `nixos-24.05-darwin` -> `https://releases.nixos.org/nixos/24.05-darwin/<release>/nixexprs.tar.xz`
- `nixpkgs-23.05` -> `https://releases.nixos.org/nixpkgs/23.05/<release>/nixexprs.tar.xz`
- etc.

### `PinnedRI`
A `PinnedRI` is a RI that *already* has all the information for pinning in it,
e.g. `https://example.com/archive/0.1.2.zip`

These can't be `weepin update`d, because no information about version substitution is available.  
If you want to have that possibility, create a `TemplateRI` instead, e.g. `https://example.com/archive/<version>.zip`

### Resolvable template tags and RIs
A normal template tag only defines the template name - `<name>`,
but it can also optionally define a value its initialized with - `<name=init>`,
such a tag is called a **resorvable template tag**.

`ResolvableRI`s are RIs that contain all the information to resolve them in them.  
`ChannelRI`s and `PinnedRI`s are already `ResolvableRI`s.

A `TemplateRI` can be resolvable if it contains a resolvable template tag,
e.g. `https://github.com/owner/repo/tree/<rev:0.1.0>`.

A `GitRI` can be resolvable if it's suffixed with `=init`, e.g.:
- `owner/repo=0.1.0` github with tag
- `gitlab:owner/repo=dev` gitlab with branch
- `git:https://codeberg.com/Codeberg/org=975ee655a3f19fc0554f2a3186d86c5f4a1abe7c` a resolvable `GitRI` for generic git source with an attached commit

Resolvable RIs are provided for convenience when `weepin init`ing or `weepin add`ing, instead of:
```shell
$ weepin init
$ weepin add owner/repo -r 0.1.0
$ weepin add repo/baz -r dev
```

It can become

```shell
$ weepin init
$ weepin add owner/repo=0.1.0 repo/baz=dev
```

Or even

```shell
$ weepin init owner/repo=0.1.0 repo/baz=dev
```

> [!IMPORTANT]
> `ResolvableRI`s are not `PinnedRI`s!  
> `PinnedRI`s are a special kind of RIs that are permanently pinned and cannot be upgraded  
> A resolvable `GitRI` or `TemplateRI` is still of its own kind, but it just uses different syntax  
> upon `weepin add`ing and `weepin init`ing which gives it an initial value.

## `wee`
  - `-v, --version` Prints version
  - `-h, --help` Prints help

  Defaults to `weepin -h`

## `weepin add` ((\<WeepinRI> | \<ResolvableRI>) \[POSITIONAL OPTIONS])...
Positional, after each `WeepinRI` / `ResolvableRI`:
- `-n, --name <name>` Gives the pin a custom name.
  The name can use template tags.
  `GitRIs` names are derived from repo name,
  `ChannelRI`s names are derived from the channel name.
  `TemplateRI` and `PinnedRI` names are derived from the last path element without extension.
- `-V, --no-validate` Disable validating if the given resource is reachable on the network before adding.

- `-i, --interactive` Invalid for `ResolvableRI`s.
  Weepin will try to determine available versions for a given resource and prompt to pick.

- `-r, --replace [<name>=]<val>` Invalid for `ResolvableRI`s.
  Substitutes given tag `<name>` with `<val>`. `name` is optional if there's only one template tag in the `TemplateRI`.

- `-d, --depends <name>...` Defines a dependency of resource on other resource names.

Adds a specific resource to `weepin.toml` (or `<file>`).

For git RIs it adds the newest available tag or commit by default,
unless `-r, --replace` is passed (it accepts commits, tags and branches).

Since `GitRI`s are implicit `TemplateRI`s `-r` works, you can think of it as `--revision` if that helps ;).

It can be also launched with the `-i, --interactive` flag to pick the revision.

`-i` will fail for `ChannelRI`s, `PinnedRI`s and `TemplateRI`s.

> [!IMPORTANT]
> This action creates the `weepin/` sources.

### Examples

```shell
$ weepin add owner/repo=0.1.0
$ weepin add owner/repo=0.1.0 -n myrepo owner/repo2 -d myrepo
$ weepin add owner/repo=0.1.0 -Vn myrepo https://example.com/<ver>.com -t 0.1.1
$ weepin add https://gitlab.company.com/group/owner/repo=f0784ec
$ weepin add git:https://gitea.foo.com/owner/repo -ri develop
$ weepin add https://example.com/<ver>.tar.xz -t 0.1.1 # We can omit the name because there's only one `ver`
$ weepin add https://example.com/<name>/<ver>.tar.xz -t ver=0.1.1 -t name=foo
```

## `weepin init` \[OPTIONS] \[(\<WeepinRI > | \<ResolvableRI>) \[POSITIONAL OPTIONS]]...
Positional, after each `WeepinRI` / `ResolvableRI`:
- `-n, --name <name>` Gives the pin a custom name.
  The name can use template tags.
  `GitRIs` names are derived from repo name,
  `ChannelRI`s names are derived from the channel name.
  `TemplateRI` and `PinnedRI` names are derived from the last path element without extension.

- `-V, --no-validate` Disable validating if the given resource is reachable on the network before adding.

- `-i, --interactive` Invalid for `ResolvableRI`s.
  Weepin will try to determine available versions for a given resource and prompt to pick.

- `-r, --replace [<name>=]<val>` Invalid for `ResolvableRI`s.
  Substitutes given tag `<name>` with `<val>`. `name` is optional if there's only one template tag in the `TemplateRI`.

Initializes `weepin/` (or `<dir>`) and `weepin.toml` (or `<file>`).

Subsequent invocations will overwrite `weepin/` (or `<dir>`) and `weepin.toml` (or `<file>`).

Unlike `npins` and `niv` doesn't track anything by default,  
if you want to init with e.g. `nixos-unstable` do `weepin init nixos-unstable`.

> [!IMPORTANT]
> This action creates the `weepin/` sources.

### Examples

Same as `weepin add` + the `-d` option:
```shell
$ weepin init owner/repo=0.1.0 owner/repo2=0.1.1
$ weepin init https://gitlab.company.com/group/owner/repo/<ver> -t f0784ec -d pins
```

## `weepin pin-dirty` \[OPTIONS] Options:
- `-i, --interactive` Invalid for `ResolvableRI`s.
- `-g, --generate` Regenerate the `weepin/` sources.

Weepin will try to determine available versions for a given resource and prompt to pick.  
Parses the `weepin.toml` file and looks for [dirty pins](#dirty-pin), modifies the file in place
with pinned dependencies.

### Examples

Same as `weepin add` + the `-d` option
```shell
$ weepin init owner/repo=0.1.0 owner/repo2=0.1.1
$ weepin init https://gitlab.company.com/group/owner/repo/<ver> -t f0784ec -d pins
```

## `weepin show` \[OPTIONS] \[\<name> \[POSITIONAL OPTIONS]]...
Positional options, after each `<name>`:
- `-a, --attrs=attrs...` Picks certain attributes, see [`weepin.toml` structure](#weepintoml-structure) for reference.

Options:
- `-f, --format pretty|json|toml` Format to use

Shows all pins matching given `name`s or all if nothing else provided.  
Names can use the `*` glob.

### Examples

```shell
$ weepin show neovim -a=name,rev -f json
$ weepin show
$ weepin show neovim nvim-luapad neogit
```
## `weepin remove` \<name>...

Removes given pins.  
Accepts `*` glob.

> [!IMPORTANT]
> This action modifies the generated `weepin/` sources.

### Examples

```shell
$ weepin remove nixos-unstable
$ weepin remove foo bar baz*
$ weepin remove nvim-*
```

## `weepin clear`

Removes all pins from `weepin.toml` or `<file>`.

> [!IMPORTANT]
> This action modifies the generated `weepin/` sources.

## `weepin repin` [<name> \[POSITIONAL ARGUMENTS]]...
Positional arguments:
- `-r, --replace [<name>=]<val>` Invalid for `ResolvableRI`s.
  Substitutes given tag `<name>` with `<val>`. `name` is optional if there's only one template tag in the `TemplateRI`.

> [!IMPORTANT]
> This action modifies the generated `weepin/` sources.

Without any arguments updates all pins.

With name arguments updates given pins.

With positional `-r` changes given parameters of a pin, typically version.

### Examples

```shell
$ weepin repin # Updates everything
$ weepin repin neovim -t v0.9.5 # Rollback to 0.9.5
```

# `weepin.toml` structure

```toml
[neovim]
ref = 'github:neovim/neovim'
tag = ''
```

<!-- TODO: This -->

# `weepin/` directory

> [!IMPORTANT]
> The **only two** garuantees about this directory are:  
> - It's importable from Nix via `import ./weepin {};`
> (note the `{}` at the end! It's a function to allow for additional arguments passed to the internal loader for future versions)  
> - The structure and properties below are guaranteed
>  
> This is to allow changes to the structure and files inside for future versions.

## Properties

- Each pin has an `outPath` generated by its respective fetcher, which means it can be used as `src` for derivations
- Each pin's name is unchanged

## Structure

`A(B)` means that `A` inherits attributes from `B`.

These are the abstract RI kinds and their guaranteed attributes after importing.  
Note that these are abstract and don't fully reflect the contents of the internal lock file
or `weepin.toml`:
- `PinnedRI`:
  - `kind`: `"pinned"|"template"|"channel"|"git"|"github"|"gitlab"` - Kind of the resource
  - `url`: `string` - Fully resolvable (no templates) url of the resource
  - `hash`: `string` - Hash of the resource
  - `outPath` - The result of evaluating a fetcher for the given source

  - `TemplateRI(PinnedRI)`:
    - `extra.template`: `string` - Template for `url`, see [`TemplateRI`](#templateri)
    - `extra.attrs`: `table<string, string>` - Used template tags and their values

    - `ChannelRI(TemplateRI)`:
      - `extra.attrs.release`: `string` - Specific release.
          This is not e.g., `nixos-unstable`, but `nixos-24.11pre641786.d603719ec6e2`.
          If you want the channel name just use the name of the pin.

    - `GitRI(TemplateRI)`:
      - `extra.attrs.owner`: `string` - Owner name
      - `extra.attrs.name`: `string` - Repository name
      - `extra.attrs.commit`: `string` - Specific commit
      - `extra.attrs.branch`: `string` - Specific branch
      - `extra.attrs.tag`: `string|null` - Set if `extra.repo.commit` belongs to a tag

      - `GitlabRI(GitRI)`:
        - `extra.attrs.group`: `string|null` - Optional group name

An example with all of the kinds above (`hash` and `outPath` ommited for brievity):
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
      repo = {
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

For technical details regarding this directory see [the technical spec](./technical.md).

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


- Interactive `TemplateRIs`
  For `TemplateRIs` that don't match channel or template RIs `-i` will try to ask what files are available
  via the given protocol.

  Supported protocols are `ssh`, `http`, `https` and `ftp`.

- Searching/showing based on types, owners and such?

- -D and -W options?

- Rolling back, enforcing tracking by git?

- Caching of downloaded `weepin add`?

- Homepage, description, such?
