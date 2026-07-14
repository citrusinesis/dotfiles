#!/usr/bin/env bash
set -euo pipefail

info() { printf '\033[0;34m==>\033[0m \033[0;32m%s\033[0m\n' "$1"; }

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

info "Updating Go modules"
(cd "$root/templates/go" && nix develop path:. --command bash -euc 'go get -u ./...; go mod tidy')

info "Updating Python dependencies"
(cd "$root/templates/python" && nix develop path:. --command uv lock --upgrade)

info "Updating Rust crates"
(cd "$root/templates/rust" && nix develop path:. --command cargo update)

info "Updating Bun dependencies and generated Nix sources"
(
  cd "$root/templates/typescript-bun"
  nix develop path:. --command bash -euc 'bun update; bun2nix --lock-file bun.lock --output-file bun.nix'
)

info "Updating Node dependencies and the pinned pnpm dependency hash"
(
  cd "$root/templates/typescript-node"
  nix develop path:. --command bash -euc \
    'pnpm update --latest; nix-update --flake --version skip --no-src default'
)
