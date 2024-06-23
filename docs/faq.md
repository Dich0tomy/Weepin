<!-- vim-markdown-toc GFM -->

* [FAQ](#faq)
  * [1. Why not npins or niv?](#1-why-not-npins-or-niv)
  * [2. Why C++?](#2-why-c)
  * [3. Why JSON5?](#3-why-json5)
  * [4. Rewrite it in *](#4-rewrite-it-in-)

<!-- vim-markdown-toc -->

# FAQ

## 1. Why not npins or niv?

My main pain point was the fact that I cannot declaratively specify my dependencies.
I also wanted a nice and quick method of dirty adding deps without pinning and then
running some magic command which would pin with the latest versions.

## 2. Why C++?

- it's the language I know the best,
- it's fast if used correctly,
- with enough knowledge it's still a viable language for new projects

## 3. Why JSON5?

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

## 4. Rewrite it in *

No.
