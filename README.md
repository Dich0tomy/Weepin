> [!NOTE]
> This is still during development.
> 0.1.0 hasn't even rolled out yet.

# Weepin

A robust declarative (hjson)/interactive (weepin add) nix pinning system akin to niv/npins.

TODO:
- [x] Finish [functional spec](./docs/spec/0.1/functional.md) and [technical spec](./docs/spec/0.1/technical.md) first draft
- [x] Consider `weepin issue`
- [x] `weepin version` which lists the weepin version with embedded loader and lockfile version
- [x] Move the generated structure of weepin to functional
- [x] Change `weepin.json5` name to more generic name - manifest
- [x] Think about channels generated structure
- [x] Talk with nobbz about why he strongly believes inputs for nix only
- [x] Refine the name inference spec
- [x] Decide between hjson and nix, make a draft, ask people
- [x] Add a definition for the `weepin/` folder
- [ ] List differences and similarities between niv and npins (in terms of interface as well!!!)
  Go back to my message on ghostty discord and list these in functional.md

- [ ] Create hjson2nix
- [ ] Add CONTRIBUTING.md with my conventions (for example not using pragma once)
- [ ] Impl that shit:
  - [ ] ?
- [ ] Create a lua lib/module/stuff?
- [ ] Add nix shell and default for Nix2

Planned features:
- [ ] Implement rate limit protection
