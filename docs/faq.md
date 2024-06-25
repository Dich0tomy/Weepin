<!-- vim-markdown-toc GFM -->

* [FAQ](#faq)
  * [1. Why not npins or niv?](#1-why-not-npins-or-niv)
  * [2. Why C++?](#2-why-c)
  * [3. Why HJSON?](#3-why-hjson)
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

## 3. Why HJSON?

When I was designing the syntax I considered the following configuration formats:
- Dhall - too verbose, unfamiliar, not enough adoption, doesn't meet my needs
- Nickel - too verbose, unfamiliar, not enough adoption, doesn't meet my needs
- HCL - too verbose, unfamiliar, not enough adoption, doesn't meet my needs
- Pkl - unfamiliar, not enough adoption
- TOML - doesn't meet my needs
- lua - doesn't meet my needs, too verbose
- Nix - there are several problems with it:
  - In certain cases it's a little bit verbose
  - Users would be able to fully code it, but then the tool wouldn't be able
  to parse and modify it in in-situ
- JSON - too verbose, ugly, ew.
- JSON5
  - turned out to meet my needs
  - it's fairly familiar because it's basically JSON but with comments and with not as many quotes
  - isn't verbose

- HJSON - basically JSON5, **but** better, because it's simpler and has a little bit more relaxed syntax!

Sadly, there isn't `builtins.importHJSON`, but I bundle an HJSON parser (see the [hjson2nix project](#)). <!-- LINK ONE DAY -->

## 4. Rewrite it in *

No. Well.. maybe someday, but for now it stays in C++.
