{ pkgs, ... }:

{
  home.packages = with pkgs; [
    nodejs
    bun
    typescript-language-server
    typescript
    prettier
    eslint
    pnpm
  ];
}
