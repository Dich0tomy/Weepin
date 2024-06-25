# Table of Contents

<!-- vim-markdown-toc GFM -->

* [Functional spec of weepin](#functional-spec-of-weepin)
* [What is Weepin](#what-is-weepin)
  * [Why not use flake inputs?](#why-not-use-flake-inputs)
  * [Main objectives](#main-objectives)
  * [Common use cases](#common-use-cases)
    * [Bootstrapping a Nix project](#bootstrapping-a-nix-project)
    * [Tracking a nixpkgs branch](#tracking-a-nixpkgs-branch)
    * [Importing packages from GitHub](#importing-packages-from-github)
    * [Using custom URLs](#using-custom-urls)
  * [Differences between npins and niv](#differences-between-npins-and-niv)
    * [Prototyping speed](#prototyping-speed)
    * [Optimized for git and channels](#optimized-for-git-and-channels)
  * [General info](#general-info)
* [Sample usage](#sample-usage)
* [Conventions](#conventions)
* [Definitions](#definitions)
  * [Consumer](#consumer)
  * [Pin](#pin)
  * [Weepin loader](#weepin-loader)
  * [Final syntax](#final-syntax)
  * [Dirty pin](#dirty-pin)
    * [Dirty channel resources](#dirty-channel-resources)
    * [Dirty git resources](#dirty-git-resources)
    * [Dirty template resources](#dirty-template-resources)
  * [Template tag](#template-tag)
  * [Name inference](#name-inference)
    * [Name inference priority](#name-inference-priority)
    * [`PinnedRI`s and `TemplateRI`s inference](#pinnedris-and-templateris-inference)
    * [`GitRI` inference](#gitri-inference)
  * [Resource Identifiers](#resource-identifiers)
    * [`PinnedRI`](#pinnedri)
    * [`ChannelRI`](#channelri)
    * [`GitRI`](#gitri)
      * [Specific services RIs](#specific-services-ris)
    * [`TemplateRI`](#templateri)
    * [Resolvable template tags and RIs](#resolvable-template-tags-and-ris)
* [Cli interface](#cli-interface)
  * [`weepin`](#weepin)
  * [`weepin init`](#weepin-init)
    * [Examples](#examples)
  * [`weepin add`](#weepin-add)
    * [Examples](#examples-1)
  * [`weepin pin-dirty`](#weepin-pin-dirty)
    * [Examples](#examples-2)
  * [`weepin show`](#weepin-show)
    * [Examples](#examples-3)
  * [`weepin repin`](#weepin-repin)
    * [Examples](#examples-4)
  * [`weepin remove`](#weepin-remove)
    * [Examples](#examples-5)
  * [`weepin clear`](#weepin-clear)
  * [`weepin version`](#weepin-version)
* [The manifest file](#the-manifest-file)
  * [Pinned resources](#pinned-resources)
  * [Channel resources](#channel-resources)
  * [Git resources](#git-resources)
    * [GitHub](#github)
    * [GitLab](#gitlab)
    * [SourceHut](#sourcehut)
    * [generic Git](#generic-git)
  * [Templated resources](#templated-resources)
* [The weepin store](#the-weepin-store)
  * [Structure](#structure)
  * [Properties](#properties)
* [Features for this release](#features-for-this-release)
* [Non-goals for this release](#non-goals-for-this-release)
* [Goals for the **next** release](#goals-for-the-next-release)
* [Goals for *some* future release](#goals-for-some-future-release)
* [Not sure if I'll ever implement these](#not-sure-if-ill-ever-implement-these)
* [Non-goals for **any** release](#non-goals-for-any-release)
* [Known issues and questions](#known-issues-and-questions)

<!-- vim-markdown-toc -->

# Functional spec of weepin

> [!NOTE]
> This is a **pre implementation** draft, which means it's *just* an idea and no code yet.
> It may change if I see some technical limitations (like slow nix evals).

# What is Weepin

Weepin is an application for pinning nix sources interactively and declaratively.

I wasn't 100% happy with both npins and niv so I made this.

If  you're not familar with the tools above - they are used to pin resources, not necesarilly Nix ones.  
Sample resources include nix channels, sources for plugins, assets and such.

## Why not use flake inputs?

First and foremost - flakes haven't been stabilized yet and not everyone (yes, really!) uses them and the experimental nix commands.
One can say that we already have nix channels accessible via the `<name>` syntax.

Yes, we do - but they're not reproducible, as they depend on the fact that such a channel with a given name
must exist on the host system, and there are no guarantees about what exactly the channel is pinned to.

Such users benefit greatly for pinning tools like niv, npins or weepin!

And as for users that do use flakes - flakesallow to pin non-nix resources with `flake = false`,
but this isn't very idiomatic and has a couple problems.
I've talked with lots of people who strongly believe Nix inputs should only be used for Nix sources.  

- Flakes haven't been finalized yet as well, so pinning such resources with `inputs` can be not future proof.
- Nix has to query the pinned resources each time to make sure they are in sync (which can also cause rate limits!).
- Each flake that uses the flake with resources in inputs also inherits those inputs (recursively if `inputs.name.flake` isn't `false`!)

## Main objectives

- [x] Be optimized for git and channel resources as these are the most commonly pinned resources
- [x] Have a manifest file
- [x] Have a simple and easily prototypable manifest syntax
- [x] Have a simple CLI interface
- [x] Be future proof
- [x] Make it hard to do things wrong

## Common use cases

<!-- TODO: Use this for differences between npins and niv -->

This section lists the same things as [niv's common use cases](https://github.com/nmattia/niv?tab=readme-ov-file#getting-started):

### Bootstrapping a Nix project

<!-- TODO: Weepin should also probably generate a default.nix by default-->

```shell
$ weepin init
...
$ tree
.
├── default.nix # Pass in -f to create a flake.nix instead
├── weepin.hjson
└── weepin
    ├── sources.json
    └── sources.nix

1 directory, 4 files
```

### Tracking a nixpkgs branch

<!-- TODO: Thing about channels more - allowing tracking by git and such -->
<!-- TODO: Is that true? Should I be tracking something? -->
Weepin doesn't add anything by default, if you want to track a channel:

### Importing packages from GitHub

The add command will infer information about the package being added, when possible.
This works very well for GitHub repositories. Run this command to add jq to your project:

```
$ weepin add stedolan/jq
```

For more examples see [`weepin add`](#weepin-add)

### Using custom URLs

It is possible to use weepin to fetch packages from custom URLs.
Run this command to add the Haskell compiler GHC to your [weepin store](#the-weepin-store).

```shell
$ weepin add 'https://downloads.haskell.org/~ghc/<version>/ghc-<version>-i386-deb8-linux.tar.xz' -r 8.4.3
```

The option -r sets the `version` tag to `8.4.3` (`-r` is for `--replace`, since there's only one tag we don't have to pass in the name).
Unlike niv, weepin automatically recognizes the above as a template tag, so we don't have to pass in `-t`.

The type of the dependency is guessed from the provided URL template, if -T is not specified.

For updating the version of GHC used run this command:

```
$ niv repin ghc -r 8.6.2
```

## Differences between npins and niv

TBD.
<!-- TODO -->

### Prototyping speed

Weepin is made specifically for speed, you can dirtily list your resources in a file and then run a command to actually pin them.
Neither niv nor npins have that feature.

### Optimized for git and channels

Weepin is optimized for git and channel resources in many places.

Git resource identifiers and their respective manifest syntax are compact and concise.

Channel names are simply.. channel names - `weepin add nixos-unstable`, `weepin add nixos-unstable -n nixpkgs`
  - In npins to pin a github resource you'd do:
  ```shell
  npins add github foo bar
  ```

  But if that github resource doesn't have a tag defined, you'd have to specify each commit by hand **with** a branch attached:
  ```shell
  npins add github --branch branch --at commit foo bar
  ```

  - In niv


- Definitely more future proof than niv and npins (for the end user), the interface is clearly defined for the user
    and the implementation part is easily extendable without breaking the interface.

## General info

- The name of the main executable is `weepin`.
- The main entrypoint of weepin is [the manifest](#the-manifest-file) which contains weepin sources.  
  They *can* but *don't have to* contain version information at this point (see [Dirty pin](#dirty-pin)).  

The source of truth for pins is the [weepin store](#the-weepin-store).

Sources can either be added with `weepin add ...`, while `weepin init`ing or added to the file directly.
[`weepin add`](#weepin-add) and [`weepin init`](#weepin-init) automatically regenerate [the weepin store](#the-weepin-store),
but after changing the file you have to [`weepin pin-dirty`](#weepin-pindirty).

Certain operations will automatically warn if dirty pins will be detected.

Weepin will generate a `weepin/` directory which is to be imported - see [The weepin store](#the-weepin-store) for more details.  

```nix
pinned = import ./weepin {};
```

# Sample usage

<!-- TODO -->
<!-- Note about how it's not 100% pinning for unsure resources -->
<!-- Note about not using versions in resources, ideally -->

# Conventions

- `foo...` one or more of foo

- `(foo bar)` group of things, typically used together with `...`

- `[foo]` optional group

- `[foo]...` optional group of things

- `[, ...]` denotes more optional items of the same kind as before

- `(foo | bar)` foo or bar, exclusive

# Definitions

## Consumer

The consumer is the nix file which imports [The weepin store](#the-weepin-store),
either `flake.nix` or `*.nix`.

## Pin

Pin loosely refers to a dependency pinned to a specific revision, version, url, etc.  
Also refers to specific items in [the manifest](#the-manifest-file).

## Weepin loader

Internal machinery ran when doing `import ./weepin {}` that loads all the pins.

## Final syntax

The syntax that is a 100% valid [manifest](#the-manifest-file) syntax, can be parsed and used by the [weepin loader](#weepin-loader).

Note, that the syntax of the file has to be a 100% conformant with the underlying manifest format, it's just that
weepin enforces a certain structure of the file of form:

```hjson
name: ...
name: ...
name: ...
```

But most of the resource kinds provide dirty versions which allow for quick prototyping.  
See [Dirty pin](#dirty-pin) for more info.

## Dirty pin

An item in [the manifest](#the-manifest-file) that doesn't have all the necessary
information for pinning, like git revision or template values.

A dirty pin is also an item that has an incorrect [final syntax](#final-syntax).

Only git, channel and template resources can be dirty.

[`weepin pin-dirty`](#wee-pin-dirty-options-options) is used to pin dirty pins.

### Dirty channel resources

```hjson
nixpkgs: '' # DIRTY, not pinned
```

### Dirty git resources

This lists all valid dirty git resource syntaxes:
```hjson
# name: GitRI - DIRTY, because there's no version
repo: owner/repo

# GitRI: '' - DIRTY, because there's no version & it's not a proper final syntax
owner/repo: ''

# GitRI: '',- DIRTY, because it's not a proper final syntax
owner/repo/0.1.0: ''

# DIRTY, because it doesn't have the proper final syntax
owner/repo: 0.1.0 # for git resources the rhs can be a tag, a commit or a branch
gitlab#owner/repo/0.1.0: ''
gitlab#group/owner/repo: 0.1.0
git#gitea.fooga.com/owner/repo/0.1.0: ''
git#98.0.12.8/owner/repo: 0.1.0

# The above get expanded to
repo: owner/repo/0.1.0
repo: gitlab#owner/repo/0.1.0
repo: gitlab#group/owner/repo/0.1.0
repo: git#gitea.fooga.com/owner/repo/0.1.0
repo: git#98.0.12.8/owner/repo/0.1.0
```

### Dirty template resources

This lists all valid dirty template resource syntaxes:
```hjson
name: { # DIRTY, not expanded template
  template: 'https://example.com/foo-<ver>.tar.gz'
}

# DIRTY, not expanded template
name: 'https://example.com/foo-<ver>.tar.gz'

# DIRTY, not final syntax
'https://example.com/foo-<ver>.tar.gz': ''
# We have to quote here because it contains `:` in the URL

# The above get expanded to
name2: {
  template: 'https://example.com/foo-<ver>.tar.gz'
  ver: 0.1.0
},

# DIRTY, not expanded template
name: 'https://example.com/foo-<ver>.tar.gz'

# DIRTY, not final syntax
'https://example.com/foo-<ver>.tar.gz': ''
# We have to quote here because it contains `:` in the URL
```

## Template tag

A template tag a special substring of form `<name>` or `<name:init>` which is later expanded with a specific value.

The latter is a special type of a template tag called a `resolvable template tag`.  
See [Resolvable template tags and RIs](#resolvable-template-tags-and-ris) below for more information on that.

The name `tag` and `template tag` is used interchangeably.

## Name inference

Name inference is a mechanism of inferring pin names from resource identifiers.

It's used in the commandline while adding RIs without explicit `-n, --name`.
`weepin` will inform about inferred names.

> [!NOTE]
> After readnig this section you may wonder why isn't `<ver>` used
> anywhere in the inference chain. The answer to that is that we want to keep the users away from potentially
> unsafe or unstable things.
>
> Suggesting the version in the name may sound okay at first thought, but if you
> repin the resource later it will either not tell the truth anymore or you will have to update
> the name and references in your code as well.
>
> It's the same reason we don't allow for template tags in pin names.

Read [Resource identifiers](#resource-identifiers) first.

### Name inference priority

If a name is inferred and another name like this already exists,
the name inference mechanism will try to infer a longer name, with certain priority, if possible.

Otherwise, it will error.

### `PinnedRI`s and `TemplateRI`s inference

For templated resources the inference is only done *after* expanding the tags.

**sld** - second level domain.

URLs are deconstructed like so:
- `https://foo.bar.baz.example.com/fooga-0.1.tar.xz`
- `https://foo.bar.baz.<sld>.com/<name>-<ver>.tar.xz`

Valid `<name>` is *anything* after `/` and before `-`.
Valid `<ver>` are semver versions and simple versions like `1` and `0.1`.

Inference priority:
- `<name>` - `fooga`
- `<sld>-<name>-<ver>` - `example-fooga`
- **error**

### `GitRI` inference

Internally, `GitRI`s are turned into `TemplateRI`s, the specific tags are not disclosed as they are implementation
defined and we don't want to couple user's perceived interface with the implementation, but
the exposition only tags for this case are:
- `<name>` - name of the repository
- `<owner>` - owner of the repository
- `<group>` - group in which the repository resides, this doesn't *always* exist

Inference priority:
- `<name>` - `foo`
- `<owner>-<name>` - `bar-foo`
- `<group>-<owner>-<name>` - `qoox-bar-foo` (if exists)
- **error**

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

Internally they are turned into `TemplateRI`s of specific services URLs with `<owner>` `<repo>` and `<rev>` tags
(this is important if you want to fully understand how name inference for them works).

#### Specific services RIs

`GitRI`s have several forms:
- GitHub:
  - `owner/repo`
  - `gh#owner/repo`
  - `github#owner/repo`
- GitLab:
  - `gl#[group/]owner/repo`
  - `gitlab#[group/]owner/repo`
  - `gitlab#32.92.0.15[/group]/owner/repo`
  - `gitlab.example.com[/group]/owner/repo` (note the `.` here, it's `gitlab.example.com`, not `gitlab#example.com` nor `gitlab#gitlab.example.com`)
- SourceHut -
  - `srht#owner/repo`
  - `sourcehut#owner/repo`
- generic git source -
  - `git#example.com[group/]/owner/repo`
  - `git#127.0.0.1[group/]/owner/repo`

> [!NOTE]
> These are not *necesarilly* reflected in the internal lockfile or manifest.

Also see:
  - [Resolvable template tags and RIs](#resolvable-template-tags-and-ris).

### `TemplateRI`
Contains [template tags](#template-tag).  
Template tags get expanded from attributes passed on the commandline or from their init values if they're [resolvable](#resolvable-template-tags-and-ris).

Some examples:
- `http://example.com/archive/<version>.zip`
- `http://example.com/archive/<name>-<version>.zip`

Also see:
  - [Resolvable template tags and RIs](#resolvable-template-tags-and-ris).

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
- `gitlab#owner/repo/dev` gitlab with branch
- `git#codeberg.com/Codeberg/org/975ee655a3f19fc0554f2a3186d86c5f4a1abe7c` a resolvable `GitRI` for generic git source with an attached commit

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
  - `-h, --help` Prints help

  Defaults to `weepin -h`

  There's no `-v, --version`, use [`weepin version`](#weepin-version) instead.

Subcommands:
  - `add`
  - `init`
  - `pin-dirty`
  - `show`
  - `remove`
  - `clear`
  - `repin`

## `weepin init`
  `[OPTIONS] [(<WeepinRI > | <ResolvableRI>) [POSITIONAL OPTIONS]]...`

Positional, after each `WeepinRI` / `ResolvableRI`:
- `-n, --name <name>` Gives the pin a custom name.

- `-f, --flake [bare | parts]`
    - Without argument or with `bare` generates a bare flake,
    - With `parts` generates a flake with flake parts

- `-i, --interactive` Invalid for `ResolvableRI`s.
  Weepin will try to determine available versions for a given resource and prompt to pick.

- `-r, --replace [<name>=]<val>` Invalid for `ResolvableRI`s.
  Substitutes given tag `<name>` with `<val>`. `name` is optional if there's only one template tag in the `TemplateRI`.

Initializes [the weepin store](#the-weepin-store) and [the manifest](#the-manifest-file).
Subsequent invocations will overwrite these.

Unlike `npins` and `niv` doesn't track anything by default,  
if you want to init with e.g. `nixos-unstable` do `weepin init nixos-unstable`.

> [!IMPORTANT]
> This action creates the `weepin/` sources.

### Examples

Same as `weepin add` + the `-d` option:
```shell
$ weepin init owner/repo=0.1.0 owner/repo=0.1.1
$ weepin init https://gitlab.company.com/group/owner/repo/<ver> -t f0784ec -d pins
```

## `weepin add`
  `((<WeepinRI> | <ResolvableRI>) [POSITIONAL OPTIONS])...`

Positional, after each `WeepinRI` / `ResolvableRI`:
- `-n, --name <name>` Gives the pin a custom name.

- `-i, --interactive` Invalid for `ResolvableRI`s.
  Weepin will try to determine available versions for a given resource and prompt to pick.

- `-r, --replace [<name>=]<val>` Invalid for `ResolvableRI`s.
  Substitutes given tag `<name>` with `<val>`. `name` is optional if there's only one template tag in the `TemplateRI`.

Adds a specific resource to [the manifest](#the-manifest-file).

For git RIs it adds the newest available tag or commit by default,
unless `-r, --replace` is passed (it accepts commits, tags and branches).

Since `GitRI`s are implicit `TemplateRI`s `-r` works, you can think of it as `--revision` if that helps ; ).

It can be also launched with the `-i, --interactive` flag to pick the revision.

`-i` will fail for `ChannelRI`s, `PinnedRI`s and `TemplateRI`s.

> [!IMPORTANT]
> This action creates the `weepin/` sources.

### Examples

```
$ weepin add owner/repo/0.1.0
$ weepin add owner/repo/0.1.0 -n myrepo owner/repo -d myrepo
$ weepin add owner/repo/0.1.0 -n myrepo https://example.com/<ver>.com -t 0.1.1 -n resource
$ weepin add gitlab.company.com/group/owner/repo/f0784ec
$ weepin add git#gitea.foo.com/owner/repo -r develop
$ weepin add git#gitea.foo.com/owner/repo -i # Will try to determine available revisions
$ weepin add https://example.com/fooga-<ver>.tar.xz -t 0.1.1 # We can omit the name because there's only one `ver`, name will be inferred from `fooga-<ver>.tar.xz` to be `fooga`
$ weepin add https://example.com/<ver>.tar.xz -t 0.1.1 # Name will be inferred from second level domain to be `example`
$ weepin add https://example.com/<name>/<ver>.tar.xz -t ver=0.1.1 -tname=foo
```

## `weepin pin-dirty`
  `[OPTIONS]`

Options:
- `-i, --interactive` Invalid for `ResolvableRI`s.
- `-g, --generate` Regenerate the `weepin/` sources.

Weepin will try to determine available versions for a given resource and prompt to pick.  
Parses [the manifest](#the-manifest-file) file and looks for [dirty pins](#dirty-pin), modifies the file in place
with pinned dependencies.

### Examples

Same as `weepin add` + the `-d` option
```shell
$ weepin init owner/repo=0.1.0 owner/repo=0.1.1
$ weepin init https://gitlab.company.com/group/owner/repo/<ver> -t f0784ec -d pins
```

## `weepin show`
  `[OPTIONS] [<name> [POSITIONAL OPTIONS]]...`

Positional options, after each `<name>`:
- `-a, --attrs=attrs...` Picks certain attributes, see [the manifest structure](#the-manifest-file) for reference.

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

Removes all pins from [the manifest](#the-manifest-file).

> [!IMPORTANT]
> This action modifies the generated `weepin/` sources.

## `weepin version`

Lists the weepin version, loader version and lock version, in a format:
- `<weepin version>+<loader version>.<lock version>` (valid semver), e.g `0.1.1+2.3`

# The manifest file

Refers to the declarative file for listing resources - `weepin.hjson`.

The format is [HJSON](https://hjson.github.io/).

The format is dead simple:
```
name: val
...
```
The name and value only need quoting (via `'` or `"`) if they contain `:` or start with a number.
The comments are `//` and `#`.
Accepts optional root levle braces.
Accepts semicolons at the end of each field.

All of the values in each category evaluate to the same.
If they are marked as `DIRTY` that means they're a [dirty pin](./functional.md#dirty-pin)
and will need to be expanded by [`weepin pin-dirty`](#wee-pin-dirty-options-options).

The general [final syntax](./technical.md#final-syntax) is
```hjson
name: ...
```

The syntax of the file is **specifically** optimized for `GitRI`s are these
are the most commonly pinned resources.

## Pinned resources

Doesn't have dirty versions.

The valid syntax is
```hjson
name: <fully resolvable URL>
```
e.g.:
```hjson
example: 'https://example.com/archive/0.1.2.zip'
foo-cf8c: 'https://some-git-service.user.com/cf8c87fafe/archive/foo.tar.gz'
```

## Channel resources

For dirty versions see - [Dirty channel resources](#dirty-channel-resources).

The valid syntax is
```hjson
name: <channel name>
```
e.g.
```hjson
nixos-unstable: nixos-unstable
nixos-stable: nixos-23.11
```

Valid channel names are all the folder names under [`https://channels.nixos.org`](https://channels.nixos.org),  
e.g. `nixos-unstable`, `nixpkgs-unstable`, `nixos-24.11`, `nixos-24.05`, `nixpkgs-24.05-darwin`.

## Git resources

For dirty versions see - [Dirty git resources](#dirty-git-resources).

### GitHub

`gh` and `github` here can be used interchangeably like in GitHub `GitRI`.  
See [Specific services URIs](./functional.md#specific-services-uris) for details.

```hjson
# Full form:
repo: {
  service: github
  owner: owner # Owner is set here, repo name is pin name
  rev: 0.1.0 # Tag, commit or branch
}

repo: { # If service is omitted it's `github` by default
  owner: owner
  rev: 0.1.0
}

repo: owner/repo/0.1.0
```

### GitLab

`gl` and `gitlab` here can be used interchangeably like in GitLab `GitRI`.  
See [Specific services URIs](./functional.md#specific-services-uris) for details.

```hjson
# Full form:
repo: {
  service: gitlab
  group: group # Not everyone is in a group so this can be omitted
  owner: owner  # Owner is set here, repo name is pin name
  rev: 0.1.0 # Tag, commit or branch
}

repo: {
  service: gitlab.own.com
  owner: owner
  rev: 0.1.0
}

repo: {
  service: gitlab#127.0.0.1
  owner: owner
  rev: 0.1.0
}

repo: gl:owner/repo/0.1.0
```

### SourceHut

`srht` and `sourcehut` here can be used interchangeably like in SourceHut `GitRI`.  
See [Specific services URIs](./functional.md#specific-services-uris) for details.

```hjson
# Full form:
repo: {
  service: srht
  owner: owner  # Owner is set here, repo name is pin name
  rev: 0.1.0 # Tag, commit or branch
}

repo: srht#owner/repo/0.1.0
```

### generic Git

```hjson
# Full form:
repo: {
  service: git#example.com
  owner: owner # Owner is set here, repo name is pin name
  rev: 0.1.0 # Tag, commit or branch
}

repo: git#52.98.12.111/owner/repo/0.1.0
```

## Templated resources

For dirty versions see - [Dirty channel resources](#dirty-channel-resources).

```hjson
# Full form:
fooga: {
  # Define the template
  template: "https://example.com/foo-<ver>.tar.gz",
  # And simply list the values
  ver: "0.1.0",
},

name: {
  template: "https://example.com/<name>-<ver>.tar.gz",
  name: "foo",
  ver: "0.1.0",
},
```

# The weepin store

Refers to the `weepin/` directory which is the source of truth for pinned packages.

> [!IMPORTANT]
> The **only two** guarantees about this directory are:  
> - It's importable from Nix via `import ./weepin {};`
> (note the `{}` at the end! It's a function to allow for additional arguments passed to the internal loader for future versions)  
> - The structure and properties below are guaranteed
>  
> This is to allow changes to the structure and files inside for future versions.

## Structure

This is the structure generated for the user **after** doing `import ./weepin {}`.

These are the abstract kinds and their guaranteed attributes after importing.  
Note that these don't reflect and are not reflect by the `RI`s and they don't reflect the contents of the internal lock file or `weepin.hjson`.

`A(B)` means that `A` inherits attributes from `B`.

- `Resource`:
  - `kind`: `"pinned"|"template"|"channel"|"git"|"github"|"gitlab"` - Kind of the resource

- `Pinned(Resource)`:
  - `url`: `string` - Fully resolvable (no templates) url of the resource
  - `hash`: `string` - Hash of the resource
  - `outPath` - The result of evaluating a fetcher for the given source

- `Template(Pinned)`:
  - `extra.template`: `string` - Template for `url`, see [`Template`](#templateri)
  - `extra.attrs`: `table<string, string>` - Used template tags and their values

- `Channel(Template)`:
  - `extra.attrs.name`: `string` - Specific channel name.
  - `extra.attrs.release`: `string` - Specific release. Used for repinning later.
      This is not e.g., `nixos-unstable`, but `nixos-24.11pre641786.d603719ec6e2`.

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

## Properties

- Each pin has an `outPath` generated by its respective fetcher, which means it can be used as `src` for derivations
- Each pin's name is unchanged

# Features for this release

- The CLI interface described above 
- Stable interface for the result of importing `weepin/`
- [The manifest file](#the-manifest-file)

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

- `weepin issue` - Something I always wanted to fiddle with - posting issues inside the executable,
  how would that work?

  Since the executable *already* runs on the computer and has access to all the context it would simply gather it
  and make an issue on the weepin repository for the user.

  This command would ask if it should include certain fields, as some info may be confidential.

  The executable would also allow to post as user (some config on user end, e.g., the `gh` binary would be required)
  or anonymously (via a github bot).

- Rolling back, enforcing tracking by git?

- Dirty template resources? (see [Known issues and questons](#known-issues-and-questions), `1.`)

- Caching of downloaded `weepin add`? `./.cache` or `./weepin/cache`?

- Homepage, description, such? Like what niv has

# Non-goals for **any** release

- Config for `import ./weepin {}`, but in [the manifest](#the-manifest-file).
  I want the manifest to be the declarative source of truh for resources,  
  and the `weepin/` directory to be the only source of truth for pinned packages with the machinery inside  
  and `import ./weepin { ... }` to be the only way to configure certain aspects of importing.

# Known issues and questions

1. Is it even possible to query an http[s] resource for available files?
