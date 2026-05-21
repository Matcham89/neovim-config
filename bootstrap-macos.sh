#!/usr/bin/env bash

set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This bootstrap script is for macOS only."
  exit 1
fi

if ! xcode-select -p >/dev/null 2>&1; then
  echo "Xcode Command Line Tools are required."
  echo "Run: xcode-select --install"
  exit 1
fi

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew is required."
  echo "Install it from: https://brew.sh/"
  exit 1
fi

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
target_dir="$config_home/nvim"

echo "Installing Homebrew packages from Brewfile..."
brew bundle --file="$repo_root/Brewfile"

if ! command -v tflint &>/dev/null; then
  echo "Installing tflint from GitHub releases..."
  arch=$(uname -m); [[ "$arch" == "arm64" ]] && arch="arm64" || arch="amd64"
  latest=$(curl -fsSL https://api.github.com/repos/terraform-linters/tflint/releases/latest | jq -r .tag_name)
  curl -fsSL "https://github.com/terraform-linters/tflint/releases/download/${latest}/tflint_darwin_${arch}.zip" -o /tmp/tflint.zip
  unzip -oq /tmp/tflint.zip -d /tmp tflint
  install -m 0755 /tmp/tflint /usr/local/bin/tflint
  rm /tmp/tflint.zip /tmp/tflint
  echo "tflint ${latest} installed."
else
  echo "tflint already installed, skipping."
fi

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  echo "Installing oh-my-zsh..."
  RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "oh-my-zsh already installed, skipping."
fi

mkdir -p "$config_home"

if [[ "$repo_root" != "$target_dir" ]]; then
  if [[ -L "$target_dir" ]]; then
    current_link="$(readlink "$target_dir" || true)"
    if [[ "$current_link" != "$repo_root" ]]; then
      backup_path="${target_dir}.backup.$(date +%Y%m%d%H%M%S)"
      mv "$target_dir" "$backup_path"
      echo "Backed up existing nvim symlink to $backup_path"
    fi
  elif [[ -e "$target_dir" ]]; then
    backup_path="${target_dir}.backup.$(date +%Y%m%d%H%M%S)"
    mv "$target_dir" "$backup_path"
    echo "Backed up existing nvim config to $backup_path"
  fi

  if [[ ! -L "$target_dir" ]] || [[ "$(readlink "$target_dir" || true)" != "$repo_root" ]]; then
    ln -sfn "$repo_root" "$target_dir"
    echo "Linked $target_dir -> $repo_root"
  fi
fi

echo "Syncing LazyVim plugins..."
nvim --headless "+Lazy! sync" +qa

echo "Bootstrap complete."
