# Bun App Template

TypeScript app template with a Nix-managed Bun runtime and Biome tooling.

## Included

- `bun` runtime and bundler
- `biome` for lint and format (replaces ESLint + Prettier)
- `typescript`, `typescript-language-server`
- `bun build`-based `nix build`

## Commands

```bash
nix develop
bun run src/index.ts
biome check .
nix build
nix run
```
