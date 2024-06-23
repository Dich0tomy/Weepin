> [!NOTE]
> This is still during development.
> 0.1.0 hasn't even rolled out yet.

# Weepin

A robust declarative (json5)/interactive (weepin add) nix pinning system akin to niv/npins.

TODO:
- [ ] Finish [functional spec](./docs/spec/0.1/functional.md) and [technical spec](./docs/spec/0.1/technical.md)
- [ ] Create json52nix
- [ ] Impl that shit:
  - [ ] ?
- [ ] Create a lua lib/module/stuff?
- [ ] Add nix shell and default for Nix2

# FAQ

1. Why not npins or niv?

My main pain point was the fact that I cannot declaratively specify my dependencies.
I also wanted a nice and quick method of dirty adding deps without pinning and then
running some magic command which would pin with the latest versions.

2. Why C++?

- it's the language I know the best,
- it's fast if used correctly,
- with enough knowledge it's still a viable language for new projects

2. Why JSON5?

When I was designing the syntax I considered the following configuration formats:
- Dhall - too verbose, unfamiliar, not enough adoption, doesn't meet my needs
- HCL - too verbose, unfamiliar, not enough adoption, doesn't meet my needs
- Pkl - unfamiliar, not enough adoption
- JSON - too verbose, ugly, ew.
- TOML - doesn't meet my needs
- JSON5
  - turned out to meet my needs
  - it's fairly familiar because it's basically JSON but with comments and with not as many quotes
  - isn't verbose

Sadly, there isn't `builtins.importJSON5`, but I bundle a json5 parser.
<!-- TODO: Bundle internally or pin -->

3. Rewrite it in *

No.
