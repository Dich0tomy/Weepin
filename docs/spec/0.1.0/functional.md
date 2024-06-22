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

## Definitions

- `WeeURI`
  - A `WeeURI` is either a `GitURI`, `TemplateURI` or `PinnedURI`
  - A `GitURI` doesn't contain any template tags which are denoted in angle brackets - `<>`
  - A `TemplateURI` contains template tags. Template tags get expanded from attributes passed on the commandline.
    A template tag is of form `<name>` or `<name1|name2[,|...]>`,
    or alternatively `<name:val>`, `<name:val|name2:val[,|...>`, see `ResolvableTemplateURI`s below.

  - A `PinnedURI` is a URI that *already* has all the information for pinning in it,
    e.g. `https://releases.nixos.org/nixpkgs/nixpkgs-24.11pre642175.90338afd6177/nixexprs.tar.xz`

  - A `ResolvableTemplateURI` is a shorthand form of `TemplateURI` which contains the value next to the
    template tag. e.g. `https://github.com/foo/bar/tree/<rev:0.1.0>`  late tags.
    
    These are available for <!-- TODO -->

  Template tags get expanded from attributes passed on the commandline.

  All `GitURI`s get turned into `TemplateURI`s inside, to easily substitute branches, revision, etc.

  <!-- Make resolable git uris -->
  `GitURI`s match `owner/repo` are recognized as unless prefixed with a certain service name:
  - `foo/bar` -> `https://github.com/foo/bar/tree/<rev>`
  - `github:foo/bar` -> `https://github.com/foo/bar/tree/<rev>`
  - `gitlab:foo/bar` -> `https://gitlab.com/foo/bar/-/tree/<rev>`
  - `sourcehut:foo/bar` -> `https://gitlab.com/foo/bar/-/tree/<rev>`
  - `codeberg:foo/bar` -> `https://gitlab.com/foo/bar/-/tree/<rev>`
  - `git:foo/bar` -> `https://gitlab.com/foo/bar/-/tree/<rev>`
  - etc.
  <!-- TODO: Figure services out -->

  Supported services:
  - git - for other
  - gitea
  - github
  - gitlab
  - codeberg
  - sourcehut

  `ChannelURIs` match the `^\w*?-\d{2}\.\d{2}(?:\w*?)?$` regex and resolve to nixos channel exprs:
  \[\<release> is determined at runtime]
  - `nixos-23.11` -> `https://releases.nixos.org/nixos/23.11/<release>/nixexprs.tar.xz` 
  - `nixos-unstable` -> `https://releases.nixos.org/nixos/unstable/<release>/nixexprs.tar.xz`
  - `nixos-24.05-darwin` -> `https://releases.nixos.org/nixos/24.05-darwin/<release>/nixexprs.tar.xz`
  - `nixpkgs-23.05` -> `https://releases.nixos.org/nixpkgs/23.05/<release>/nixexprs.tar.xz`
  - etc.

  To specify a full URL you specify a `TemplateURI`, basically a URI with a template tag inside, like so:
  - `http://example.com/archive/<version>.zip`

  Or you can specify a full `PinnedURI`, these can't be `wee update`d, though:
  - `https://example.com/archive/0.1.2.zip`


## `wee`
  - `-v, --version` Prints wee version
  - `-h, --help` Prints help

  Defaults to `wee -h`

## `wee add` \[OPTIONS] \<WeeURI>
  - `-V, --no-validate` Disable validating if the given resource is reachable on the network before adding
  - `-i, --interactive` Weepin will try to determine available versions for a given resource and prompt to pick
  - `-a, --attr <name>:<val>` Substitutes given attribute `<name>` with `<val>`
  - `-r, --revision <rev>` Short for `-a rev:<rev>`

  Adds a specific resource to `weepin.toml`.

  For git URIs it adds the newest available tag or commit by default,
  unless `-r, --revision` is passed (it accepts commits, tags and branches).

  It can be also launched with the `-i, --interactive` flag to pick the revision.

  `-i` will fail for `ChannelURI`s and `PinnedURI`s

Adds a 

## `wee init`
Initializes `weepin/` and `weepin.toml`.
It doesn't track anything by default.

## `wee remove`

## `wee update`

# `weepin.toml` structure

<!-- This should be very stable! -->

```toml
[neovim]
ref = 'github:neovim/neovim'
tag = ''
```


# `weepin/`

No assumptions about that directory should be made other than
the fact that the directory is importable from Nix.
This is to allow changes to the structure

<!-- This should contain `version` and be backwards compatible -->

# Non-goals
- Importing
  This release won't support importing sources from niv/npins or `flake.lock`.

- Weepin dir operations
  Operations on the `weepin/` directory which would upgrade
  the framework.
  - `migrate` Migrates to new format, saves info about previous version
    - `-c, --check` Run `nix flake check` after runnnig `migrate`
  - `restore` Restores format to the previous one


- Interactive TemplateURIs
  For `TemplateURIs` that don't match channel or template URIs `-i` will try to ask what files are available
  via the given protocol.

  Supported protocols are `ssh`, `http`, `https` and `ftp`.
