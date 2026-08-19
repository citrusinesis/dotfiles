#!/usr/bin/env bash
set -euo pipefail

info() { printf '\033[0;34m==>\033[0m \033[0;32m%s\033[0m\n' "$1"; }
error() { printf '\033[0;31mError:\033[0m %s\n' "$1" >&2; exit 1; }

tmp_dir="$(mktemp -d)"
cleanup() { rm -rf "$tmp_dir"; }
trap cleanup EXIT
trap 'exit 1' HUP INT TERM

download() {
  local url="$1"
  local destination="$2"

  curl --proto '=https' --tlsv1.2 --fail --location --silent --show-error \
    --output "$destination" "$url"
  chmod 0700 "$destination"
}

download_verified() {
  local url="$1"
  local destination="$2"
  local expected_sha256="$3"
  local actual_sha256

  download "$url" "$destination"

  if command -v sha256sum &>/dev/null; then
    actual_sha256="$(sha256sum "$destination" | awk '{print $1}')"
  elif command -v shasum &>/dev/null; then
    actual_sha256="$(shasum -a 256 "$destination" | awk '{print $1}')"
  else
    error "Neither sha256sum nor shasum is available to verify $url"
  fi

  if [[ "$actual_sha256" != "$expected_sha256" ]]; then
    error "Checksum mismatch for $url (expected $expected_sha256, got $actual_sha256)"
  fi
}

find_nix_binary() {
  local candidate
  local candidates=()

  if command -v nix &>/dev/null; then
    command -v nix
    return 0
  fi

  candidates+=(
    /nix/var/nix/profiles/default/bin/nix
    /nix/var/nix/profiles/system/sw/bin/nix
    /run/current-system/sw/bin/nix
  )

  if [[ -n "${HOME:-}" ]]; then
    candidates+=("$HOME/.nix-profile/bin/nix")
  fi

  for candidate in "${candidates[@]}"; do
    if [[ -x "$candidate" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done

  return 1
}

has_nix_installation_footprint() {
  command -v nix-store &>/dev/null \
    || [[ -d /nix/store ]] \
    || [[ -e /nix/receipt.json ]] \
    || [[ -e /nix/nix-installer ]] \
    || [[ -e /nix/lix-installer ]] \
    || [[ -e /etc/nix/nix.conf ]]
}

# Reuse any existing Nix implementation. Install Lix only on a clean machine.
if existing_nix="$(find_nix_binary)"; then
  if ! existing_nix_details="$("$existing_nix" --version 2>&1)"; then
    error "An existing Nix installation was found at $existing_nix, but it is not usable: $existing_nix_details"
  fi
  existing_nix_version="${existing_nix_details%%$'\n'*}"
  info "Using existing Nix installation: $existing_nix_version ($existing_nix)"
elif has_nix_installation_footprint; then
  error "An existing or incomplete Nix installation was detected, but no usable nix command was found. Repair its PATH or uninstall it before re-running bootstrap.sh."
else
  info "Installing Lix"
  # Upstream does not publish installer checksum manifests. Use its official
  # TLS-protected bootstrap only after ruling out every existing Nix install.
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
    homebrew_installer_rev="cced90146ea6d3057c03a636b668fef177415eb3"
    homebrew_installer_sha256="12479a24be3f5307eecac7cde670fad7118640f031229e964f544b1367b52a41"
    homebrew_installer_url="https://raw.githubusercontent.com/Homebrew/install/$homebrew_installer_rev/install.sh"
    download_verified "$homebrew_installer_url" "$brew_installer" "$homebrew_installer_sha256"
    /bin/bash "$brew_installer"
  fi
fi

info "Ready — run 'nix run .#activate' to apply configuration (afterwards use 'sw' or update-and-switch with 'up')"
