# Node App Template

TypeScript app template with a Nix-managed Node runtime, pnpm, and Biome tooling.

## Included

- `nodejs` runtime and `pnpm` package manager
- `biome` for lint and format (replaces ESLint + Prettier)
- `typescript`, `typescript-language-server`
- `tsc`-based `nix build`

## Commands

```bash
nix develop
pnpm install
biome check .
nix build
nix run
```
