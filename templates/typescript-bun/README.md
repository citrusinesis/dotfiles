# Bun App Template

TypeScript app template with a Nix-managed Bun runtime and Biome tooling.

## Included

- `bun` runtime and bundler with `bun2nix`
- `biome` for lint and format (replaces ESLint + Prettier)
- `typescript`, `typescript-language-server`
- `bun.lock` and generated `bun.nix` consumed by `nix build`

## Commands

```bash
nix develop
bun install --frozen-lockfile
bun run src/index.ts
biome check .
nix build
nix run
```

Before the first commit, replace `bun-app` in `flake.nix`, `package.json`, and
`src/index.ts`.

After changing dependencies, regenerate `bun.nix` with
`bun2nix --lock-file bun.lock --output-file bun.nix`; the lock check rejects a
stale generated file.
