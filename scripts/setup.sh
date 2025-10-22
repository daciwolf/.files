#!/usr/bin/env bash

# Enable strict mode only when executed directly, not when sourced.
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  set -euo pipefail
fi

# If sourced, re-run in a subshell so failures don't close the parent shell.
if [[ "${BASH_SOURCE[0]}" != "$0" ]]; then
  bash "${BASH_SOURCE[0]}" "$@"
  return
fi

echo "🔧 Starting portable dotfiles setup..."

# Detect OS
OS="$(uname -s)"
case "$OS" in
  Linux*)     MACHINE=Linux;;
  Darwin*)    MACHINE=Mac;;
  CYGWIN*|MINGW*|MSYS*) MACHINE=Windows;;
  *)          MACHINE="UNKNOWN:$OS";;
esac
echo "Detected OS: $MACHINE"

# Ensure local bin exists
mkdir -p "$HOME/.local/bin"
export PATH="$HOME/.local/bin:$PATH"

# Add to rc files if missing
for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
  if [ -f "$rc" ] && ! grep -q ".local/bin" "$rc"; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$rc"
  fi
done

# -------- Install Neovim (local binary) --------
install_nvim_local() {
  if ! command -v nvim >/dev/null 2>&1; then
    echo "Installing Neovim locally..."
    cd "$HOME/.local/bin"
    if [[ "$MACHINE" == "Mac" ]]; then
      curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-macos.tar.gz
      tar xzf nvim-macos.tar.gz
      mv nvim-macos/bin/nvim "$HOME/.local/bin/nvim"
      rm -rf nvim-macos nvim-macos.tar.gz
    elif [[ "$MACHINE" == "Linux" ]]; then
      curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
      chmod u+x nvim.appimage
      mv nvim.appimage nvim
    else
      echo "Neovim install skipped (unsupported on this platform)"
    fi
  else
    echo "Neovim already installed"
  fi
}

# -------- Install clangd (local binary) --------
install_clangd_local() {
  if command -v clangd >/dev/null 2>&1; then
    echo "clangd already installed"
    return 0
  fi

  echo "Installing clangd locally..."
  cd "$HOME/.local/bin"
  if [[ "$MACHINE" == "Linux" ]]; then
    if command -v wget >/dev/null 2>&1; then
      wget -q https://github.com/clangd/clangd/releases/latest/download/clangd-linux.zip -O clangd.zip || { echo "Failed to download clangd (wget). Skipping."; return 0; }
    elif command -v curl >/dev/null 2>&1; then
      curl -fsSL https://github.com/clangd/clangd/releases/latest/download/clangd-linux.zip -o clangd.zip || { echo "Failed to download clangd (curl). Skipping."; return 0; }
    else
      echo "Neither wget nor curl found. Skipping clangd install."
      return 0
    fi

    if command -v unzip >/dev/null 2>&1; then
      unzip -q clangd.zip || { echo "unzip failed; skipping clangd install."; rm -f clangd.zip; return 0; }
    elif command -v bsdtar >/dev/null 2>&1; then
      bsdtar -xf clangd.zip || { echo "bsdtar failed; skipping clangd install."; rm -f clangd.zip; return 0; }
    else
      echo "No unzip/bsdtar found. Install 'unzip' and re-run for clangd."
      rm -f clangd.zip
      return 0
    fi

    extracted_dir="$(find . -maxdepth 1 -type d -name 'clangd_*' | head -n1)"
    if [[ -n "$extracted_dir" ]]; then
      mv "$extracted_dir"/* "$HOME/.local/" || true
      rm -rf "$extracted_dir" clangd.zip || true
    else
      echo "Could not locate extracted clangd directory; skipping move."
      rm -f clangd.zip || true
    fi
  elif [[ "$MACHINE" == "Mac" ]]; then
    brew install llvm || echo "Couldn't install clangd; please install manually"
  else
    echo "clangd install skipped (unsupported on this platform)"
  fi
}

# -------- Ensure Bash exists --------
install_bash_local() {
  if ! command -v bash >/dev/null 2>&1; then
    echo "Bash not found."
    if [[ "$MACHINE" == "Linux" ]]; then
      echo "Attempting local Bash build..."
      cd "$HOME/.local"
      curl -LO https://ftp.gnu.org/gnu/bash/bash-5.2.tar.gz
      tar xzf bash-5.2.tar.gz && cd bash-5.2
      ./configure --prefix="$HOME/.local" && make && make install
      cd .. && rm -rf bash-5.2 bash-5.2.tar.gz
    elif [[ "$MACHINE" == "Mac" ]]; then
      brew install bash || echo "Install failed; using /bin/sh fallback"
    elif [[ "$MACHINE" == "Windows" ]]; then
      winget install --id Git.Git -e --source winget || echo "Install Git Bash manually"
    fi
  else
    echo "Bash already installed"
  fi
}

install_bash_local
install_nvim_local
install_clangd_local

# -------- Link configs --------
if [[ "$MACHINE" == "Windows" ]]; then
  CONFIG_DIR="$APPDATA"
else
  CONFIG_DIR="$HOME/.config"
fi

# Resolve this script's directory for robust linking regardless of CWD
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$CONFIG_DIR/nvim" "$CONFIG_DIR/wezterm"
ln -sf "$SCRIPT_DIR/../nvim/init.lua" "$CONFIG_DIR/nvim/init.lua"
ln -sf "$SCRIPT_DIR/../wezterm/wezterm.lua" "$CONFIG_DIR/wezterm/wezterm.lua"

echo "Configuration complete!"

