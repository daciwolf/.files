#!/usr/bin/env bash
set -e

echo "🔧 Starting portable dotfiles setup..."

# Detect OS
OS="$(uname -s)"
case "$OS" in
    Linux*)     MACHINE=Linux;;
    Darwin*)    MACHINE=Mac;;
    CYGWIN*|MINGW*|MSYS*) MACHINE=Windows;;
    *)          MACHINE="UNKNOWN:$OS"
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
  if ! command -v clangd >/dev/null 2>&1; then
    echo "Installing clangd locally..."
    cd "$HOME/.local/bin"
    if [[ "$MACHINE" == "Linux" ]]; then
      wget -q https://github.com/clangd/clangd/releases/latest/download/clangd-linux.zip -O clangd.zip
      unzip -q clangd.zip
      mv clangd_*/* "$HOME/.local/"
      rm -rf clangd_* clangd.zip
    elif [[ "$MACHINE" == "Mac" ]]; then
      brew install llvm || echo "Couldn't install clangd; please install manually"
    fi
  else
    echo "clangd already installed"
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
ln -sf "$(pwd)/../nvim/init.lua" "$CONFIG_DIR/nvim/init.lua"
ln -sf "$(pwd)/../wezterm/wezterm.lua" "$CONFIG_DIR/wezterm/wezterm.lua"

echo "Configuration complete!"
