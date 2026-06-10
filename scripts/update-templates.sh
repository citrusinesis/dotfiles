#!/usr/bin/env bash
set -euo pipefail

info() { printf '\033[0;34m==>\033[0m \033[0;32m%s\033[0m\n' "$1"; }

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

for template in "$root"/templates/*/; do
  [[ -f "$template/flake.nix" ]] || continue
  info "Updating $(basename "$template")"
  nix flake update --flake "path:${template%/}"
done
