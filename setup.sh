#!/usr/bin/env bash
set -euo pipefail

info() { printf '\033[0;34m==>\033[0m \033[0;32m%s\033[0m\n' "$1"; }
error() { printf '\033[0;31mError:\033[0m %s\n' "$1" >&2; exit 1; }

# Lix
if command -v nix &>/dev/null; then
  info "Lix/Nix already installed: $(nix --version)"
else
  info "Installing Lix"
  curl -sSf -L https://install.lix.systems/lix | sh -s -- install
  info "Restart your shell, then re-run this script"
  exit 0
fi

# Homebrew (macOS only)
if [[ "$(uname)" == "Darwin" ]]; then
  if command -v brew &>/dev/null; then
    info "Homebrew already installed: $(brew --version | head -1)"
  else
    info "Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
fi

info "Ready — run 'nix run .#activate' to apply configuration"
