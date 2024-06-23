<!-- vim-markdown-toc GFM -->

* [Functional spec of weepin](#functional-spec-of-weepin)
* [Sample usage](#sample-usage)
* [Conventions](#conventions)
* [Definitions](#definitions)
  * [Pin](#pin)
  * [Weepin loader](#weepin-loader)
  * [Final syntax](#final-syntax)
  * [Dirty pin](#dirty-pin)
    * [Dirty channel resources](#dirty-channel-resources)
    * [Dirty git resource pins](#dirty-git-resource-pins)
    * [Dirty template resource pins](#dirty-template-resource-pins)
    * [Template tag](#template-tag)
    * [Name inference](#name-inference)
  * [Resource Identifiers](#resource-identifiers)
    * [`PinnedRI`](#pinnedri)
    * [`ChannelRI`](#channelri)
    * [`GitRI`](#gitri)
      * [Specific services RIs](#specific-services-ris)
    * [`TemplateRI`](#templateri)
    * [Resolvable template tags and RIs](#resolvable-template-tags-and-ris)
* [Cli interface](#cli-interface)
  * [`weepin`](#weepin)
  * [`weepin add`](#weepin-add)
    * [Examples](#examples)
  * [`weepin init`](#weepin-init)
    * [Examples](#examples-1)
  * [`weepin pin-dirty`](#weepin-pin-dirty)
    * [Examples](#examples-2)
  * [`weepin show`](#weepin-show)
    * [Examples](#examples-3)
  * [`weepin remove`](#weepin-remove)
    * [Examples](#examples-4)
  * [`weepin clear`](#weepin-clear)
  * [`weepin repin`](#weepin-repin)
    * [Examples](#examples-5)
* [The `weepin.json5` file](#the-weepinjson5-file)
  * [Pinned resources](#pinned-resources)
  * [Channel resources](#channel-resources)
  * [Git resources](#git-resources)
    * [GitHub](#github)
    * [GitLab:](#gitlab)
    * [SourceHut](#sourcehut)
    * [generic Git](#generic-git)
  * [Templated resources](#templated-resources)
* [The `weepin/` directory](#the-weepin-directory)
  * [Properties](#properties)
* [Common use cases](#common-use-cases)
* [Differences between npins and niv](#differences-between-npins-and-niv)
* [Features for this release](#features-for-this-release)
* [Non-goals for this release](#non-goals-for-this-release)
* [Goals for the **next** release](#goals-for-the-next-release)
* [Goals for *some* future release](#goals-for-some-future-release)
* [Not sure if I'll ever implement these](#not-sure-if-ill-ever-implement-these)
* [Non-goals for **any** release](#non-goals-for-any-release)
* [Known issues](#known-issues)

<!-- vim-markdown-toc -->

# Functional spec of weepin

> [!NOTE]
> This is a **pre implementation** draft, which means it's *just* an idea and no code yet.
> It may change if I see some technical limitations (like slow nix evals).

Weepin is an application for pinning nix sources interactively and declaratively.

I wasn't 100% happy with both npins and niv so I made this.

If  you're not familar with the tools above - they are used to pin resources, not necesarilly Nix ones.  
Sample resources include nix channels, sources for plugins, assets and such.

Flakes allow to pin such with `flake = false`, but this typically neither suffices nor is idiomatic.  
I've discussed with lots of people who strongly believe Nix inputs should only be used for Nix sources.  
Flakes haven't been finalized yet as well, so pinning such resources with `inputs` can be not future proof.

- The name of the main executable is `weepin`.
- The main entrypoint of weepin is `weepin.json5` which contains weepin sources.  
  They *can* but *don't have to* contain version information at this point (see [Dirty pin](#dirty-pin)).  

The source of truth for pins is the `weepin/` directory.

Sources can either be added with `weepin add ...`, while `weepin init`ing or added to the file directly.
[`weepin add`](#weepin-add) and [`weepin init`](#weepin-init) automatically regenerate [the `weepin/` directory](#the-weepin-directory),
but after changing the file you have to [`weepin pin-dirty`](#weepin-pindirty).

Certain operations will automatically warn if dirty pins will be detected.

Weepin will generate a `weepin/` directory which is to be imported - see [The `weepin/` directory](#the-weepin-directory) for more details.  

```nix
pinned = import ./weepin {};
```

# Sample usage

<!-- TODO -->

# Conventions

- `foo...` one or more of foo

- `(foo bar)` group of things, typically used together with `...`

- `[foo]` optional group

- `[foo]...` optional group of things

- `[, ...]` denotes more optional items of the same kind as before

- `(foo | bar)` foo or bar, exclusive

# Definitions

## Pin

Pin loosely refers to a dependency pinned to a specific revision, version, url, etc.  
Also refers to specific items in the [`weepin.json5` file](#the-weepinjson5-file).

## Weepin loader

Internal machinery ran when doing `import ./weepin {}` that loads all the pins.

## Final syntax

The syntax that is a 100% valid `weepin.json5` syntax, can be parsed and used by the weepin loader.

Note, that the syntax of the file has to be a 100% conformant with `JSON5`, it's just that
weepin enforces a certain structure of the file of form:

```json5
{
  name: ...,
  name: ...,
  name: ...,
}
```

But most of the resource kinds provide dirty versions which allow for quick prototyping.  
See [Dirty pin](#dirty-pin) for more info.

## Dirty pin

An item in [the `weepin.json5` file](#the-weepinjson5-file) that doesn't have all the necessary
information for pinning, like git revision or template values.

A dirty pin is also an item that has an incorrect [final syntax](#final-syntax).

Only git, channel and template resources can be dirty.

[`weepin pin-dirty`](#wee-pin-dirty-options-options) is used to pin dirty pins.

### Dirty channel resources

```json5
{
  nixpkgs: "", // DIRTY, not pinned
}
```

### Dirty git resource pins

```json5
{
  // DIRTY, because there's no version
  repo: "owner/repo",

  // DIRTY, because it doesn't have the proper final syntax, but this is allowed for fast prototyping
  "owner/repo2": "0.1.0", // for git resources the rhs can be a tag, a commit or a branch
  "gitlab:owner/repo3": "0.1.0",
  "gitlab:group/owner/repo4": "0.1.0",
  "git:gitea.fooga.com/owner/repo5": "0.1.0",
  "git:98.0.12.8/owner/repo6": "0.1.0",

  // The above get expanded to
  repo2: "owner/repo5/0.1.0",
  repo3: "gitlab:owner/repo2/0.1.0",
  repo4: "gitlab:group/owner/repo2/0.1.0",
  repo5: "git:gitea.fooga.com/owner/repo3/0.1.0"
  repo6: "git:98.0.12.8/owner/repo3/0.1.0"

  // DIRTY, because there's no version & it's not a proper final syntax
  "owner/repo6": "",
}
```

### Dirty template resource pins

```json5
{
  name2: { // DIRTY, not expanded template
    template: "https://example.com/foo-<ver>.tar.gz",
  },

  name: "https://example.com/foo-<ver>.tar.gz",// DIRTY, not expanded template
}
```

### Template tag

A template tag a special substring of form `<name>` or `<name:init>` which is later expanded with a specific value.

The latter is a special type of a template tag called a `resolvable template tag`.  
See [Resolvable template tags and RIs](#resolvable-template-tags-and-ris) below for more information on that.

### Name inference

Name inference is a mechanism of inferring pin names from resource identifiers.

It's used in the commandline while adding RIs without explicit `-n, --name`.
`weepin` will inform about inferred names.

For pinned and templated resources we look at the last part of the path and match `<name>.<ext>` or `<name>-<ver>.<ext>`.
Valid `<ver>` are semver versions and simple versions like `1` and `0.1`.

- `https://example.com/fooga-0.1.tar.xz` - `fooga`
- `https://example.com/fooga-<ver>.tar.xz` - `fooga`
- `https://example.com/<name>-<ver>.tar.xz` - whatever `<name>` will be after expansion

In other cases we look at the secod level domain:
- `https://example.com/<ver>.tar.xz` - `example`
- `https://foo.boo.example.com/<ver>.tar.xz` - `example`

These examples are ambiguous and will error:
- `https://example.com/bar-abc.tar.xz` - `abc` could very well be a commit but we don't know, `-n` is required

For templated resources the inference is only done after expanding the tags.

For git identifiers the name is inferred from the repository name.

## Resource Identifiers

Each of the ones below is generally referred to as a `WeepinRI` (Weepin Resource Identifier).

### `PinnedRI`
A `PinnedRI` is a RI that *already* has all the information for pinning in it,
e.g. `https://example.com/archive/0.1.2.zip`

These can't be `weepin repin`ed, because no information about version substitution is available.  
If you want to have that possibility, create a `TemplateRI` instead, e.g. `https://example.com/archive/<version>.zip`

### `ChannelRI`
`ChannelRI`s match the `^\w*?-\d{2}\.\d{2}(?:\w*?)?$` regex and resolve to nixos channel exprs:
\[\<release> is determined at runtime]
- `nixos-23.11` -> `https://releases.nixos.org/nixos/23.11/<release>/nixexprs.tar.xz` 
- `nixos-unstable` -> `https://releases.nixos.org/nixos/unstable/<release>/nixexprs.tar.xz`
- `nixos-24.05-darwin` -> `https://releases.nixos.org/nixos/24.05-darwin/<release>/nixexprs.tar.xz`
- `nixpkgs-23.05` -> `https://releases.nixos.org/nixpkgs/23.05/<release>/nixexprs.tar.xz`
- etc.

### `GitRI`
Pins to a git resource like github, gitlab, sourcehut or a generic one.

#### Specific services RIs

`GitRI`s have several forms:
- GitHub:
  - `owner/repo`
  - `gh:owner/repo`
  - `github:owner/repo`
- GitLab:
  - `gl:[group/]owner/repo`
  - `gitlab:[group/]owner/repo`
  - `gitlab:32.92.0.15[/group]/owner/repo`
  - `gitlab.example.com[/group]/owner/repo` (note the `.` here, it's `gitlab.example.com`, not `gitlab:example.com` nor `gitlab:gitlab.example.com`)
- SourceHut -
  - `srht:owner/repo`
  - `sourcehut:owner/repo`
- generic git source -
  - `git:example.com[group/]/owner/repo`
  - `git:127.0.0.1[group/]/owner/repo`

> [!NOTE]
> These are not *necesarilly* reflected in the internal lockfile or `weepin.json5`.

### `TemplateRI`
Contains [template tags](#template-tag).  
Template tags get expanded from attributes passed on the commandline or from their init values if they're [resolvable](#resolvable-template-tags-and-ris).

Some examples:
- `http://example.com/archive/<version>.zip`
- `http://example.com/archive/<name>-<version>.zip`

### Resolvable template tags and RIs
A normal template tag only defines the template name - `<name>`,
but it can also optionally define a value its initialized with - `<name:init>`,
such a tag is called a **resolvable template tag**.

`ResolvableRI`s are RIs that contain all the information to resolve them and be pinned.  
`ChannelRI`s and `PinnedRI`s are already `ResolvableRI`s.

A `TemplateRI` can be resolvable if all its tags are resolvable, e.g.:
- `https://example.com/archive/foo-<ver:0.1.0>`.
- `https://example.com/archive/<name:foo>-<ver:0.1.0>`.

A `GitRI` can be resolvable if it's suffixed with `/init`, e.g.:
- `owner/repo/0.1.0` github with tag
- `gitlab:owner/repo/dev` gitlab with branch
- `git:codeberg.com/Codeberg/org/975ee655a3f19fc0554f2a3186d86c5f4a1abe7c` a resolvable `GitRI` for generic git source with an attached commit

Resolvable RIs are provided for convenience when `weepin init`ing or `weepin add`ing, instead of:
```shell
$ weepin init
$ weepin add owner/repo -r 0.1.0
$ weepin add repo/baz -r dev
```

It can become

```shell
$ weepin init
$ weepin add owner/repo/0.1.0 repo/baz/dev
```

Or even

```shell
$ weepin init owner/repo/0.1.0 repo/baz/dev
```

> [!IMPORTANT]
> `ResolvableRI`s are not `PinnedRI`s!  
> `PinnedRI`s are a special kind of RIs that are permanently pinned and cannot be upgraded  
> A resolvable `GitRI` or `TemplateRI` is still of its own kind, but it just uses different syntax  
> upon `weepin add`ing and `weepin init`ing which gives it an initial value.


# Cli interface

## `weepin`
  - `-v, --version` Prints version
  - `-h, --help` Prints help

  Defaults to `weepin -h`

Subcommands:
  - `add`
  - `init`
  - `pin-dirty`
  - `show`
  - `remove`
  - `clear`
  - `repin`

## `weepin add`
  `((<WeepinRI> | <ResolvableRI>) [POSITIONAL OPTIONS])...`

Positional, after each `WeepinRI` / `ResolvableRI`:
- `-n, --name <name>` Gives the pin a custom name.
  The name can use template tags.
  `GitRI`s names are derived from repo name,
  `ChannelRI`s names are derived from the channel name.
  `TemplateRI` and `PinnedRI` names are derived from the last path element without extension.
- `-V, --no-validate` Disable validating if the given resource is reachable on the network before adding.

- `-i, --interactive` Invalid for `ResolvableRI`s.
  Weepin will try to determine available versions for a given resource and prompt to pick.

- `-r, --replace [<name>=]<val>` Invalid for `ResolvableRI`s.
  Substitutes given tag `<name>` with `<val>`. `name` is optional if there's only one template tag in the `TemplateRI`.

Adds a specific resource to `weepin.json5`.

For git RIs it adds the newest available tag or commit by default,
unless `-r, --replace` is passed (it accepts commits, tags and branches).

Since `GitRI`s are implicit `TemplateRI`s `-r` works, you can think of it as `--revision` if that helps ;).

It can be also launched with the `-i, --interactive` flag to pick the revision.

`-i` will fail for `ChannelRI`s, `PinnedRI`s and `TemplateRI`s.

> [!IMPORTANT]
> This action creates the `weepin/` sources.

### Examples

```shell
$ weepin add owner/repo/0.1.0
$ weepin add owner/repo/0.1.0 -n myrepo owner/repo2 -d myrepo
$ weepin add owner/repo/0.1.0 -Vn myrepo https://example.com/<ver>.com -t 0.1.1 -n resource
$ weepin add gitlab.company.com/group/owner/repo/f0784ec
$ weepin add git:gitea.foo.com/owner/repo -r develop
$ weepin add git:gitea.foo.com/owner/repo -i # Will try to determine available revisions
$ weepin add https://example.com/fooga-<ver>.tar.xz -t 0.1.1 # We can omit the name because there's only one `ver`, name will be inferred from `fooga-<ver>.tar.xz` to be `fooga`
$ weepin add https://example.com/<ver>.tar.xz -t 0.1.1 # Name will be inferred from second level domain to be `example`
$ weepin add https://example.com/<name>/<ver>.tar.xz -t ver=0.1.1 -tname=foo
```

## `weepin init`
  `[OPTIONS] [(<WeepinRI > | <ResolvableRI>) [POSITIONAL OPTIONS]]...`

Positional, after each `WeepinRI` / `ResolvableRI`:
- `-n, --name <name>` Gives the pin a custom name.
  The name can use template tags.
  `GitRI`s names are derived from repo name,
  `ChannelRI`s names are derived from the channel name.
  `TemplateRI` and `PinnedRI` names are derived from the last path element without extension.

- `-V, --no-validate` Disable validating if the given resource is reachable on the network before adding.

- `-i, --interactive` Invalid for `ResolvableRI`s.
  Weepin will try to determine available versions for a given resource and prompt to pick.

- `-r, --replace [<name>=]<val>` Invalid for `ResolvableRI`s.
  Substitutes given tag `<name>` with `<val>`. `name` is optional if there's only one template tag in the `TemplateRI`.

Initializes `weepin/` and `weepin.json5`.

Subsequent invocations will overwrite `weepin/` and `weepin.json5`.

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

## `weepin pin-dirty`
  `[OPTIONS]`

Options:
- `-i, --interactive` Invalid for `ResolvableRI`s.
- `-g, --generate` Regenerate the `weepin/` sources.

Weepin will try to determine available versions for a given resource and prompt to pick.  
Parses the `weepin.json5` file and looks for [dirty pins](#dirty-pin), modifies the file in place
with pinned dependencies.

### Examples

Same as `weepin add` + the `-d` option
```shell
$ weepin init owner/repo=0.1.0 owner/repo2=0.1.1
$ weepin init https://gitlab.company.com/group/owner/repo/<ver> -t f0784ec -d pins
```

## `weepin show`
  `[OPTIONS] [<name> [POSITIONAL OPTIONS]]...`

Positional options, after each `<name>`:
- `-a, --attrs=attrs...` Picks certain attributes, see the [`weepin.json5` structure](#the-weepinjson5-file) for reference.

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
## `weepin remove`
  `<name>...`

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

Removes all pins from `weepin.json5`.

> [!IMPORTANT]
> This action modifies the generated `weepin/` sources.

## `weepin repin`
  `[<name> [POSITIONAL ARGUMENTS]]...`

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

# The `weepin.json5` file

[JSON5 format](https://json5.org/).

All of the values in each category evaluate to the same.
If they are marked as `DIRTY` that means they're a [dirty pin](./functional.md#dirty-pin)
and will need to be expanded by [`weepin pin-dirty`](#wee-pin-dirty-options-options).

The general [final syntax](./technical.md#final-syntax) is
```
{
  name: ...,
  name: ...,
  name: ...,
}
```

The syntax of the file is **specifically** optimized for `GitRI`s are these
are the most commonly pinned resources.

## Pinned resources

Doesn't have dirty versions.
```json5
{
  example: "https://example.com/archive/0.1.2.zip",
  "foo-cf8c": "https://some-git-service.user.com/cf8c87fafe/archive/foo.tar.gz",
}
```

## Channel resources

```json5
{
  nixpkgs: "", // DIRTY, not pinned

  nixos-unstable: "nixos-unstable",
  nixos-stable: "nixos-23.11",
}
```

## Git resources

### GitHub

`gh` and `github` here can be used interchangeably like in GitHub `GitRI`.  
See [Specific services URIs](./functional.md#specific-services-uris) for details.

```json5
{
  // Full form:
  repo: {
    service: "github",
    owner: "owner", // Owner is set here, repo name is pin name
    rev: "0.1.0", // Tag, commit or branch
  },
  repo: { // If service is omitted it's `github` by default
    owner: "owner",
    rev: "0.1.0",
  },
  repo: "owner/repo/0.1.0",
  repo: "owner/repo", // DIRTY, no revision
  "gh:owner/repo": "0.1.0", // DIRTY, not final
  "owner/repo": "", // DIRTY, no revision & not final
}
```

### GitLab:

`gl` and `gitlab` here can be used interchangeably like in GitLab `GitRI`.  
See [Specific services URIs](./functional.md#specific-services-uris) for details.

```json5
{
  // Full form:
  repo: {
    service: "gitlab",
    group: "group", // Not everyone is in a group so this can be omitted
    owner: "owner",  // Owner is set here, repo name is pin name
    rev: "0.1.0", // Tag, commit or branch
  },
  repo: {
    service: "gitlab.own.com",
    owner: "owner",
    rev: "0.1.0",
  },
  repo: {
    service: "gitlab:127.0.0.1",
    owner: "owner",
    rev: "0.1.0",
  },
  repo: "gl:owner/repo/0.1.0",

  repo: "gl:owner/repo", // DIRTY, no revision
  "gl:owner/repo": "0.1.0", // DIRTY, not final
  "gl:owner/repo": "", // DIRTY, no revision & not final
}
```

### SourceHut

`srht` and `sourcehut` here can be used interchangeably like in SourceHut `GitRI`.  
See [Specific services URIs](./functional.md#specific-services-uris) for details.

```json5
{
  // Full form:
  repo: {
    service: "srht",
    owner: "owner",  // Owner is set here, repo name is pin name
    rev: "0.1.0", // Tag, commit or branch
  },
  repo: "srht:owner/repo/0.1.0",

  repo: "srht:owner/repo", // DIRTY, no revision
  "srht:owner/repo": "0.1.0", // DIRTY, not final
  "srht:owner/repo": "", // DIRTY, no revision & not final
}
```

### generic Git

```json5
{
  // Full form:
  repo: {
    service: "git:example.com",
    owner: "owner",  // Owner is set here, repo name is pin name
    rev: "0.1.0", // Tag, commit or branch
  },
  repo: "git:52.98.12.111/owner/repo/0.1.0",
  repo: "git:52.98.12.111/owner/repo", // DIRTY, no revision

  "git:gitea.me.com/owner/repo": "0.1.0", // DIRTY, not final
  "git:codeberg.womp.womp/owner/repo": "", // DIRTY, no version & not final
}
```

## Templated resources

```json5
{
  // Full form:
  name: {
    // Define the template
    template: "https://example.com/foo-<ver>.tar.gz",
    // And simply list the values
    ver: "0.1.0",
  },

  "<name>": { // You can use the template tag in the name
    template: "https://example.com/<name>-<ver>.tar.gz",
    name: "foo",
    ver: "0.1.0",
  },

  name2: { // DIRTY, not expanded template
    template: "https://example.com/foo-<ver>.tar.gz",
  },

  name: "https://example.com/foo-<ver>.tar.gz", // DIRTY, not expanded template
}
```

# The `weepin/` directory

> [!IMPORTANT]
> The **only two** guarantees about this directory are:  
> - It's importable from Nix via `import ./weepin {};`
> (note the `{}` at the end! It's a function to allow for additional arguments passed to the internal loader for future versions)  
> - The structure and properties below are guaranteed
>  
> This is to allow changes to the structure and files inside for future versions.

For technical details regarding this directory see [the technical spec](./technical.md).

## Properties

- Each pin has an `outPath` generated by its respective fetcher, which means it can be used as `src` for derivations
- Each pin's name is unchanged

# Common use cases

TODO: Fill this
<!-- TODO: Fill this -->

# Differences between npins and niv

- Allows for declarative specifying of dependencies, instead of 100% interactive via the CLI
- Allows for dirtily specifying dependencies, that is - not pinning them immediately, and then using
  the cli to automagically pin them
- TODO: Fill this

<!-- TODO: Fill this -->

# Features for this release

- The CLI interface described above 
- Stable interface for the result of importing `weepin/`
- `weepin.json5` with a structure described in [The `weepin.json5` file](#the-weepinjson5-file)

# Non-goals for this release

- Resource dependencies, the `-d` flag

- `weepin license` for polling licenses, generating NOTICE files and such?

# Goals for the **next** release

- Importing

  This release won't support importing sources from niv/npins or `flake.lock`.

- `weepin upgrade`

  The internal lock file and loader may change across releases.
  `weepin upgrade` should be provided to update the internal machinery.

# Goals for *some* future release

- Config for `import ./weepin { option = true; }`  
  Options will get added as I'll be adding and refactoring features.

- Searching, filtering based on types, owners, tags and such?

- Some support for reading .env files? Like server access tokens and such?

# Not sure if I'll ever implement these

- Rolling back, enforcing tracking by git?

- Caching of downloaded `weepin add`? `./.cache` or `./weeping/cache`?

- Homepage, description, such? Like what niv has

- Homepage, description, such? Like what niv has

# Non-goals for **any** release

- Config for `import ./weepin {}`, but in `weepin.json5`.  
  I want `weepin.json5` to be the declarative source of truh for resources,  
  and the `weepin/` directory to be the only source of truth for pinned packages with the machinery inside  
  and `import ./weeping { ... }` to be the only way to configure certain aspects of importing.

# Known issues
