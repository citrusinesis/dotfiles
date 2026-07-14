{ ... }:

{
  imports = [
    ./headless-development.nix
    ./editors/vscode.nix
    ./editors/zed.nix
    ./terminals/ghostty.nix
    ./misc/module.nix
    ./dev/winbox.nix
  ];
}
