# Neovim Config

Portable macOS-focused [LazyVim](https://www.lazyvim.org/) config.

This repo contains the current contents of `~/.config/nvim`, including:

- your LazyVim config
- `lazy-lock.json` so plugin versions stay consistent across laptops
- a macOS `Brewfile` for the local prerequisites this setup expects
- a `bootstrap-macos.sh` helper that installs packages and links the repo into `~/.config/nvim`

## Included LazyVim Extras

- ansible
- docker
- git
- go
- helm
- php
- python
- rego
- terraform
- toml
- yaml

## macOS Requirements

Baseline LazyVim requirements for this repo:

- Neovim `>= 0.11.2`
- Git `>= 2.19.0`
- a Nerd Font (optional, but recommended)
- `curl`
- `tree-sitter-cli`
- a C compiler for `nvim-treesitter`
- `fzf`, `ripgrep`, and `fd`
- `lazygit` (optional)

This repo assumes macOS and uses:

- Homebrew for package installation
- Xcode Command Line Tools for the C toolchain

## Install

If you want the repo to live directly at `~/.config/nvim`:

```bash
git clone https://github.com/Matcham89/neovim-config.git ~/.config/nvim
cd ~/.config/nvim
./bootstrap-macos.sh
```

If you want to keep the repo elsewhere and symlink it into place:

```bash
git clone https://github.com/Matcham89/neovim-config.git ~/Documents/github/neovim-config
cd ~/Documents/github/neovim-config
./bootstrap-macos.sh
```

The bootstrap script will:

1. Verify macOS and Xcode Command Line Tools.
2. Install Homebrew packages from `Brewfile`.
3. Link this repo to `~/.config/nvim` if needed.
4. Run a headless `Lazy sync` so plugins install from the lockfile.

## What Homebrew Installs

Core editor requirements:

- `neovim`
- `git`
- `fd`
- `fzf`
- `ripgrep`
- `lazygit`
- `tree-sitter-cli`
- `node`
- `python@3.13`
- `go`
- `php`

Language and workflow tools used by this config:

- `helm`
- `tflint`
- `terraform-docs`

Optional UI nicety:

- install a Nerd Font manually if you want icon support

## What Neovim Installs Automatically

On first launch, LazyVim and Mason will install the plugin and language-tooling set driven by this config, including the current servers and formatters for:

- ansible
- docker
- go
- helm
- lua
- php
- python
- rego
- terraform
- toml
- yaml

## Notes

- `lazy-lock.json` is committed so plugin versions stay aligned across machines.
- Mason-managed tools live outside this repo and are recreated automatically by the config.
- Machine-local state such as caches and plugin install directories should stay out of git.
