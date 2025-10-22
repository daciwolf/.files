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

echo "Starting portable dotfiles setup..."

# Resolve absolute script directory early (before any cd's)
if [[ "${BASH_SOURCE[0]}" = /* ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
  SCRIPT_DIR="$(cd "$(dirname "$PWD/${BASH_SOURCE[0]}")" && pwd)"
fi

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
  need_install=1
  current_ver=""
  if command -v nvim >/dev/null 2>&1; then
    # Extract version like 0.9.5 from: NVIM v0.9.5
    current_ver=$(nvim --version 2>/dev/null | head -n1 | sed -E 's/.*v([0-9]+\.[0-9]+\.[0-9]+).*/\1/')
    if [ -n "$current_ver" ]; then
      # If current >= 0.8.0 then skip install
      latest_of_two=$(printf '%s\n' "$current_ver" "0.8.0" | sort -V | tail -n1)
      if [ "$latest_of_two" = "$current_ver" ]; then
        need_install=0
      fi
    fi
  fi

  if [ "$need_install" -eq 0 ]; then
    echo "Neovim already >= 0.8 (v${current_ver})"
    return 0
  fi

  echo "Installing Neovim locally..."
  cd "$HOME/.local/bin"
  if [[ "$MACHINE" == "Mac" ]]; then
    curl -LO https://github.com/neovim/neovim/releases/download/v0.11.4/nvim-macos-arm64.tar.gz
    tar xzf nvim-macos.tar.gz
    mv nvim-macos/bin/nvim "$HOME/.local/bin/nvim"
    rm -rf nvim-macos nvim-macos.tar.gz
  elif [[ "$MACHINE" == "Linux" ]]; then
    # Try AppImage; if FUSE not available, extract and link
    url=https://github.com/neovim/neovim/releases/download/v0.11.4/nvim-linux-x86_64.appimage
    if command -v curl >/dev/null 2>&1; then
      curl -fL "$url" -o nvim.appimage || true
    elif command -v wget >/dev/null 2>&1; then
      wget -q "$url" -O nvim.appimage || true
    fi
    if [ -s nvim.appimage ]; then
      chmod u+x nvim.appimage
      # Try running to detect FUSE; if fails, extract
      if ./nvim.appimage --version >/dev/null 2>&1; then
        mv nvim.appimage nvim
      else
        ./nvim.appimage --appimage-extract >/dev/null 2>&1 || true
        if [ -d squashfs-root ]; then
          rm -rf "$HOME/.local/nvim-appimage" 2>/dev/null || true
          mv squashfs-root "$HOME/.local/nvim-appimage" 2>/dev/null || true
          ln -sf "$HOME/.local/nvim-appimage/AppRun" "$HOME/.local/bin/nvim"
          rm -f nvim.appimage
        else
          echo "Failed to extract AppImage; leaving system nvim in place."
        fi
      fi
    else
      echo "Failed to download Neovim AppImage."
    fi
  else
    echo "Neovim install skipped (unsupported on this platform)"
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
      wget -q https://github.com/clangd/clangd/releases/download/21.1.0/clangd-linux-21.1.0.zip -O clangd.zip || { echo "Failed to download clangd (wget). Skipping."; return 0; }
    elif command -v curl >/dev/null 2>&1; then
      curl -fsSL https://github.com/clangd/clangd/releases/download/21.1.0/clangd-linux-21.1.0.zip -o clangd.zip || { echo "Failed to download clangd (curl). Skipping."; return 0; }
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
      dest="$HOME/.local/clangd-dist"
      rm -rf "$dest" 2>/dev/null || true
      mv "$extracted_dir" "$dest" || true
      ln -sf "$dest/bin/clangd" "$HOME/.local/bin/clangd" || true
      rm -f clangd.zip || true
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

mkdir -p "$CONFIG_DIR/nvim" "$CONFIG_DIR/wezterm"
ln -sf "$SCRIPT_DIR/../nvim/init.lua" "$CONFIG_DIR/nvim/init.lua"
ln -sf "$SCRIPT_DIR/../wezterm/wezterm.lua" "$CONFIG_DIR/wezterm/wezterm.lua"

echo "Configuration complete!"
