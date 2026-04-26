{ ... }:

{
  flake.templates = {
    rust = {
      path = ../../templates/rust;
      description = "Fenix-backed Rust service template";
    };

    go = {
      path = ../../templates/go;
      description = "Go service template with buildGoModule and a Nix-managed toolchain";
    };

    typescript-bun = {
      path = ../../templates/typescript-bun;
      description = "TypeScript app template with a Nix-managed Bun runtime and Biome tooling";
    };

    typescript-node = {
      path = ../../templates/typescript-node;
      description = "TypeScript app template with a Nix-managed Node runtime, pnpm, and Biome tooling";
    };

    python = {
      path = ../../templates/python;
      description = "Python service template with uv-managed env, pathlib, dotenv, and tomllib config";
    };
  };
}
