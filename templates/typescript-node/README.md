# Node App Template

TypeScript app template with a Nix-managed Node runtime, pnpm, and Biome tooling.

## Included

- Nix-pinned `nodejs` runtime and pnpm 9 package manager
- `biome` for lint and format (replaces ESLint + Prettier)
- `typescript`, `typescript-language-server`
- `pnpm-lock.yaml`-backed, offline `nix build`

## Commands

```bash
nix develop
pnpm install --frozen-lockfile
biome check .
nix build
nix run
```

Before the first commit, replace `node-app` in `flake.nix`, `package.json`, and
`src/index.ts`.

Use `../../scripts/update-template-dependencies.sh` from the dotfiles checkout
to update pnpm dependencies and recalculate the Nix dependency hash together.
