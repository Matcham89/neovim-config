# Neovim Config

Portable macOS-focused [LazyVim](https://www.lazyvim.org/) config plus a Homebrew-managed shell tooling baseline.

This repo contains the current contents of `~/.config/nvim`, including:

- your LazyVim config
- `lazy-lock.json` so plugin versions stay consistent across laptops
- a macOS `Brewfile` for the local prerequisites and day-to-day CLI tools this setup expects
- a `bootstrap-macos.sh` helper that installs packages and links the repo into `~/.config/nvim`

## Included LazyVim Extras

- ansible
- docker
- git
- go
- helm
- json
- markdown
- php
- python
- rego
- terraform
- toml
- yaml

Bash has no official LazyVim extra — `bash-language-server`, `shellcheck`, and `shfmt` are installed via Mason automatically.

## Git Config

This setup expects the following in `~/.gitconfig` (not tracked in this repo):

```gitconfig
[user]
    name  = <your name>
    email = <your email>

[core]
    editor    = nvim
    autocrlf  = input
    pager     = delta

[init]
    defaultBranch = main

[pull]
    rebase = true

[push]
    default         = current
    autoSetupRemote = true

[rebase]
    autoStash = true

[merge]
    conflictstyle = diff3
    tool          = nvimdiff

[diff]
    colorMoved = default
    tool       = nvimdiff

[credential]
    helper = osxkeychain

[alias]
    lg      = log --oneline --graph --decorate --all
    st      = status -sb
    co      = checkout
    br      = branch
    unstage = reset HEAD --
    last    = log -1 HEAD
    aliases = config --get-regexp alias

```

`delta` must be installed first — it is included in the `Brewfile`.

For GitHub/GitLab integrations in Neovim (Octo), authenticate via:

```bash
gh auth login          # GitHub
GITLAB_TOKEN=<token>   # GitLab — add to your shell profile
```

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

These install commands replace any existing `~/.config/nvim`. If you want to keep the old config, move it somewhere else first.

If you want the repo to live directly at `~/.config/nvim`:

```bash
cd ~
echo "Removing existing ~/.config/nvim"
rm -rf ~/.config/nvim
git clone https://github.com/Matcham89/neovim-config.git ~/.config/nvim
cd ~/.config/nvim
./bootstrap-macos.sh
```

If you want to keep the repo elsewhere and symlink it into place:

```bash
cd ~
echo "Removing existing ~/.config/nvim"
rm -rf ~/.config/nvim
git clone https://github.com/Matcham89/neovim-config.git ~/Documents/github/neovim-config
cd ~/Documents/github/neovim-config
./bootstrap-macos.sh
```

The bootstrap script will:

1. Verify macOS and Xcode Command Line Tools.
2. Install Homebrew packages from `Brewfile` for both Neovim and the wider CLI toolchain.
3. Link this repo to `~/.config/nvim` if needed.
4. Run a headless `Lazy sync` so plugins install from the lockfile.

## What Homebrew Installs

This repo now tracks both the editor prerequisites and the broader brew-installed CLI toolbox from this machine.

Core editor requirements:

- `neovim`
- `git`
- `git-delta` — enhanced diff pager used by the git config
- `fd`
- `fzf`
- `ripgrep`
- `lazygit`
- `tree-sitter-cli`

Languages and runtimes:

- `node`
- `python@3.13`
- `go`
- `php`

Platform and infrastructure tooling:

- `argocd`
- `gh`
- `glab`
- `gcloud-cli`
- `helm`
- `jq`
- `kubectl` via `kubernetes-cli`
- `terraform-docs`
- `tfenv`
- `tflint`
- `tilt`
- `yq`

General shell and workstation utilities:

- `tmux`
- `tree`
- `font-jetbrains-mono-nerd-font`

Additional direct installs currently captured from this Mac:

- `cmatrix`
- `dnsmasq`
- `lolcat`
- `mysql@8.4`
- `tree-sitter@0.25`
- `vim`

## What Neovim Installs Automatically

On first launch, LazyVim and Mason will install the plugin and language-tooling set driven by this config, including the current servers and formatters for:

- ansible
- bash (`bash-language-server`, `shellcheck`, `shfmt`)
- docker
- go
- helm
- json
- lua
- markdown
- php
- python
- rego
- terraform
- toml
- yaml

### Git plugins (Neovim)

| Plugin | Keymaps | Purpose |
|---|---|---|
| `diffview.nvim` | `<leader>gd` diff view, `<leader>gh` file history | Full-screen diff and merge tool |
| `neogit` | `<leader>gn` | Magit-style Git UI |
| `octo.nvim` | `<leader>go` prompt, `<leader>gpr` PRs, `<leader>gpi` issues | GitHub PRs and issues in Neovim |

LazyVim also bundles `gitsigns.nvim` and `lazygit` integration out of the box.

## Notes

- `lazy-lock.json` is committed so plugin versions stay aligned across machines.
- Mason-managed tools live outside this repo and are recreated automatically by the config.
- Machine-local state such as caches and plugin install directories should stay out of git.
