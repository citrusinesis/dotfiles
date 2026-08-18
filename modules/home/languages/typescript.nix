{ pkgs, ... }:

{
  home.packages = with pkgs; [
    nodejs
    typescript-language-server
    typescript
    biome
    pnpm
  ];

  programs.bun = {
    enable = true;
    enableGitIntegration = true;
  };
}
