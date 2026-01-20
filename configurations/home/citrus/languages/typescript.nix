{ pkgs, ... }:

{
  home.packages = with pkgs; [
    nodejs
    bun
    typescript-language-server
    typescript
    nodePackages.prettier
    nodePackages.eslint
    nodePackages.pnpm
  ];
}
