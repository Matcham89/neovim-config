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
