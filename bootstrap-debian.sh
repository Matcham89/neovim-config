#!/usr/bin/env bash

set -euo pipefail

if [[ "$(uname -s)" != "Linux" ]]; then
  echo "This bootstrap script is for Debian/Ubuntu Linux only."
  exit 1
fi

if ! command -v apt-get >/dev/null 2>&1; then
  echo "apt-get not found. This script targets Debian/Ubuntu systems."
  exit 1
fi

if [[ $EUID -eq 0 ]]; then
  echo "Do not run this script as root. It will call sudo when needed."
  exit 1
fi

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
target_dir="$config_home/nvim"

arch_raw="$(uname -m)"
case "$arch_raw" in
  x86_64|amd64) arch="amd64"; arch_alt="x86_64" ;;
  aarch64|arm64) arch="arm64"; arch_alt="aarch64" ;;
  *) echo "Unsupported architecture: $arch_raw"; exit 1 ;;
esac

echo "==> Updating apt and installing base packages..."
sudo apt-get update
sudo apt-get install -y \
  build-essential \
  ca-certificates \
  curl \
  wget \
  gnupg \
  lsb-release \
  software-properties-common \
  apt-transport-https \
  unzip \
  zip \
  git \
  fzf \
  ripgrep \
  fd-find \
  jq \
  tmux \
  tree \
  vim \
  cmatrix \
  lolcat \
  dnsmasq \
  php \
  php-cli \
  python3 \
  python3-pip \
  python3-venv \
  python3-dev \
  zsh

# fd is installed as fdfind on Debian — add an `fd` shim on PATH
if ! command -v fd >/dev/null 2>&1 && command -v fdfind >/dev/null 2>&1; then
  mkdir -p "$HOME/.local/bin"
  ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
  echo "Linked fdfind -> ~/.local/bin/fd"
fi

echo "==> Installing Neovim (latest stable from GitHub releases)..."
# Debian's apt neovim is usually older than LazyVim's minimum (>= 0.11.2).
nvim_tarball="nvim-linux-${arch_alt}.tar.gz"
curl -fsSL "https://github.com/neovim/neovim/releases/latest/download/${nvim_tarball}" -o /tmp/nvim.tar.gz
sudo rm -rf /opt/nvim
sudo mkdir -p /opt/nvim
sudo tar -xzf /tmp/nvim.tar.gz -C /opt/nvim --strip-components=1
sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim
rm -f /tmp/nvim.tar.gz

echo "==> Installing git-delta..."
delta_latest=$(curl -fsSL https://api.github.com/repos/dandavison/delta/releases/latest | jq -r .tag_name)
curl -fsSL "https://github.com/dandavison/delta/releases/download/${delta_latest}/delta-${delta_latest}-${arch_alt}-unknown-linux-gnu.tar.gz" -o /tmp/delta.tar.gz
tar -xzf /tmp/delta.tar.gz -C /tmp
sudo install -m 0755 "/tmp/delta-${delta_latest}-${arch_alt}-unknown-linux-gnu/delta" /usr/local/bin/delta
rm -rf /tmp/delta.tar.gz "/tmp/delta-${delta_latest}-${arch_alt}-unknown-linux-gnu"

echo "==> Installing lazygit..."
lg_latest=$(curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest | jq -r .tag_name)
lg_version="${lg_latest#v}"
case "$arch" in
  amd64) lg_arch="x86_64" ;;
  arm64) lg_arch="arm64" ;;
esac
curl -fsSL "https://github.com/jesseduffield/lazygit/releases/download/${lg_latest}/lazygit_${lg_version}_Linux_${lg_arch}.tar.gz" -o /tmp/lazygit.tar.gz
tar -xzf /tmp/lazygit.tar.gz -C /tmp lazygit
sudo install -m 0755 /tmp/lazygit /usr/local/bin/lazygit
rm -f /tmp/lazygit.tar.gz /tmp/lazygit

echo "==> Installing Node.js (NodeSource current LTS)..."
if ! command -v node >/dev/null 2>&1; then
  curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
  sudo apt-get install -y nodejs
fi

echo "==> Installing tree-sitter-cli via npm..."
sudo npm install -g tree-sitter-cli

echo "==> Installing Go..."
if ! command -v go >/dev/null 2>&1; then
  go_version=$(curl -fsSL https://go.dev/VERSION?m=text | head -n1)
  curl -fsSL "https://go.dev/dl/${go_version}.linux-${arch}.tar.gz" -o /tmp/go.tar.gz
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf /tmp/go.tar.gz
  sudo ln -sf /usr/local/go/bin/go /usr/local/bin/go
  sudo ln -sf /usr/local/go/bin/gofmt /usr/local/bin/gofmt
  rm -f /tmp/go.tar.gz
fi

echo "==> Installing GitHub CLI (gh)..."
if ! command -v gh >/dev/null 2>&1; then
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
  sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
  sudo apt-get update
  sudo apt-get install -y gh
fi

echo "==> Installing GitLab CLI (glab)..."
if ! command -v glab >/dev/null 2>&1; then
  glab_latest=$(curl -fsSL https://api.github.com/repos/profclems/glab/releases/latest | jq -r .tag_name)
  glab_version="${glab_latest#v}"
  curl -fsSL "https://gitlab.com/gitlab-org/cli/-/releases/v${glab_version}/downloads/glab_${glab_version}_linux_${arch}.deb" -o /tmp/glab.deb \
    || curl -fsSL "https://github.com/profclems/glab/releases/download/${glab_latest}/glab_${glab_version}_Linux_${arch_alt}.tar.gz" -o /tmp/glab.tar.gz
  if [[ -f /tmp/glab.deb ]]; then
    sudo dpkg -i /tmp/glab.deb || sudo apt-get install -f -y
    rm -f /tmp/glab.deb
  else
    tar -xzf /tmp/glab.tar.gz -C /tmp
    sudo install -m 0755 /tmp/bin/glab /usr/local/bin/glab
    rm -rf /tmp/glab.tar.gz /tmp/bin
  fi
fi

echo "==> Installing kubectl..."
if ! command -v kubectl >/dev/null 2>&1; then
  kver=$(curl -fsSL https://dl.k8s.io/release/stable.txt)
  curl -fsSL "https://dl.k8s.io/release/${kver}/bin/linux/${arch}/kubectl" -o /tmp/kubectl
  sudo install -m 0755 /tmp/kubectl /usr/local/bin/kubectl
  rm -f /tmp/kubectl
fi

echo "==> Installing Helm..."
if ! command -v helm >/dev/null 2>&1; then
  curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi

echo "==> Installing ArgoCD CLI..."
if ! command -v argocd >/dev/null 2>&1; then
  argo_latest=$(curl -fsSL https://api.github.com/repos/argoproj/argo-cd/releases/latest | jq -r .tag_name)
  curl -fsSL "https://github.com/argoproj/argo-cd/releases/download/${argo_latest}/argocd-linux-${arch}" -o /tmp/argocd
  sudo install -m 0755 /tmp/argocd /usr/local/bin/argocd
  rm -f /tmp/argocd
fi

echo "==> Installing yq..."
if ! command -v yq >/dev/null 2>&1; then
  yq_latest=$(curl -fsSL https://api.github.com/repos/mikefarah/yq/releases/latest | jq -r .tag_name)
  curl -fsSL "https://github.com/mikefarah/yq/releases/download/${yq_latest}/yq_linux_${arch}" -o /tmp/yq
  sudo install -m 0755 /tmp/yq /usr/local/bin/yq
  rm -f /tmp/yq
fi

echo "==> Installing terraform-docs..."
if ! command -v terraform-docs >/dev/null 2>&1; then
  td_latest=$(curl -fsSL https://api.github.com/repos/terraform-docs/terraform-docs/releases/latest | jq -r .tag_name)
  curl -fsSL "https://github.com/terraform-docs/terraform-docs/releases/download/${td_latest}/terraform-docs-${td_latest}-linux-${arch}.tar.gz" -o /tmp/td.tar.gz
  tar -xzf /tmp/td.tar.gz -C /tmp terraform-docs
  sudo install -m 0755 /tmp/terraform-docs /usr/local/bin/terraform-docs
  rm -f /tmp/td.tar.gz /tmp/terraform-docs
fi

echo "==> Installing tfenv..."
if [[ ! -d "$HOME/.tfenv" ]]; then
  git clone --depth=1 https://github.com/tfutils/tfenv.git "$HOME/.tfenv"
fi
sudo ln -sf "$HOME/.tfenv/bin/tfenv" /usr/local/bin/tfenv
sudo ln -sf "$HOME/.tfenv/bin/terraform" /usr/local/bin/terraform

echo "==> Installing tflint..."
if ! command -v tflint >/dev/null 2>&1; then
  tf_latest=$(curl -fsSL https://api.github.com/repos/terraform-linters/tflint/releases/latest | jq -r .tag_name)
  curl -fsSL "https://github.com/terraform-linters/tflint/releases/download/${tf_latest}/tflint_linux_${arch}.zip" -o /tmp/tflint.zip
  unzip -oq /tmp/tflint.zip -d /tmp tflint
  sudo install -m 0755 /tmp/tflint /usr/local/bin/tflint
  rm -f /tmp/tflint.zip /tmp/tflint
  echo "tflint ${tf_latest} installed."
else
  echo "tflint already installed, skipping."
fi

echo "==> Installing Tilt..."
if ! command -v tilt >/dev/null 2>&1; then
  curl -fsSL https://raw.githubusercontent.com/tilt-dev/tilt/master/scripts/install.sh | bash
fi

echo "==> Installing gcloud CLI (Google Cloud SDK)..."
if ! command -v gcloud >/dev/null 2>&1; then
  curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg \
    | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
  echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" \
    | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list >/dev/null
  sudo apt-get update
  sudo apt-get install -y google-cloud-cli
fi

echo "==> Installing MySQL client/server (8.x)..."
if ! command -v mysql >/dev/null 2>&1; then
  sudo apt-get install -y default-mysql-client default-mysql-server || sudo apt-get install -y mysql-client mysql-server
fi

echo "==> Installing JetBrainsMono Nerd Font..."
fonts_dir="$HOME/.local/share/fonts"
mkdir -p "$fonts_dir"
if ! fc-list 2>/dev/null | grep -qi "JetBrainsMono Nerd Font"; then
  nf_latest=$(curl -fsSL https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest | jq -r .tag_name)
  curl -fsSL "https://github.com/ryanoasis/nerd-fonts/releases/download/${nf_latest}/JetBrainsMono.zip" -o /tmp/JetBrainsMono.zip
  unzip -oq /tmp/JetBrainsMono.zip -d "$fonts_dir/JetBrainsMono"
  rm -f /tmp/JetBrainsMono.zip
  fc-cache -f "$fonts_dir" >/dev/null 2>&1 || true
  echo "JetBrainsMono Nerd Font installed."
else
  echo "JetBrainsMono Nerd Font already installed, skipping."
fi

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  echo "==> Installing oh-my-zsh..."
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
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

echo "==> Syncing LazyVim plugins..."
nvim --headless "+Lazy! sync" +qa

echo "Bootstrap complete."
echo
echo "Notes:"
echo "  - Add \$HOME/.local/bin and /usr/local/go/bin to your PATH if not already present."
echo "  - tfenv lives at \$HOME/.tfenv — run 'tfenv install latest && tfenv use latest' to pick a Terraform."
echo "  - To make zsh your default shell: chsh -s \$(which zsh)"
