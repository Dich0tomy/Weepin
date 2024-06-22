# Weepin

A declarative/interactive nix pinning system.

TODO:
- [ ] Finish [functional spec](./docs/spec/0.1.0/functional.md) 
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

3. Rewrite it in *

No.
