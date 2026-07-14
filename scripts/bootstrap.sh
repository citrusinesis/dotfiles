#!/usr/bin/env bash
set -euo pipefail

info() { printf '\033[0;34m==>\033[0m \033[0;32m%s\033[0m\n' "$1"; }
error() { printf '\033[0;31mError:\033[0m %s\n' "$1" >&2; exit 1; }

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT HUP INT TERM

download() {
  local url="$1"
  local destination="$2"

  curl --proto '=https' --tlsv1.2 --fail --location --silent --show-error \
    --output "$destination" "$url"
  chmod 0700 "$destination"
}

# Lix (required — non-Lix Nix forks are rejected)
if command -v nix &>/dev/null; then
  if nix --version 2>&1 | grep -qi lix; then
    info "Lix already installed: $(nix --version)"
  else
    error "Existing Nix is not Lix: $(nix --version). Uninstall it first, then re-run."
  fi
else
  info "Installing Lix"
  lix_installer="$tmp_dir/lix-installer.sh"
  download "https://install.lix.systems/lix" "$lix_installer"
  /bin/sh "$lix_installer" install
  info "Lix installed. Restart your shell, then re-run bootstrap.sh to continue."
  exit 0
fi

# Homebrew (macOS only)
if [[ "$(uname)" == "Darwin" ]]; then
  if command -v brew &>/dev/null; then
    info "Homebrew already installed: $(brew --version | head -1)"
  else
    info "Installing Homebrew"
    brew_installer="$tmp_dir/homebrew-installer.sh"
    download "https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh" "$brew_installer"
    /bin/bash "$brew_installer"
  fi
fi

info "Ready — run 'nix run .#activate' to apply configuration (afterwards use 'sw' or update-and-switch with 'up')"
