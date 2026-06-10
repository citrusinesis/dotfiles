#!/usr/bin/env bash
set -euo pipefail

info() { printf '\033[0;34m==>\033[0m \033[0;32m%s\033[0m\n' "$1"; }
error() { printf '\033[0;31mError:\033[0m %s\n' "$1" >&2; exit 1; }

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source_file="$root/packages/apple-container/source.json"

info "Resolving latest apple/container release"
latest_url="$(curl -fsSLI -o /dev/null -w '%{url_effective}' https://github.com/apple/container/releases/latest)"
version="${latest_url##*/}"
[[ -n "$version" && "$version" != "latest" ]] || error "Could not resolve latest release tag"

current="$(sed -n 's/.*"version": "\([^"]*\)".*/\1/p' "$source_file" 2>/dev/null || true)"
if [[ "$version" == "$current" ]]; then
  info "Already up to date: $version"
  exit 0
fi

url="https://github.com/apple/container/releases/download/$version/container-$version-installer-signed.pkg"

info "Prefetching $url"
hash="$(nix store prefetch-file --json "$url" | sed -n 's/.*"hash": *"\([^"]*\)".*/\1/p')"
[[ -n "$hash" ]] || error "Failed to prefetch $url"

cat >"$source_file" <<EOF
{
  "version": "$version",
  "url": "$url",
  "hash": "$hash"
}
EOF

info "Updated apple-container: ${current:-none} -> $version"
