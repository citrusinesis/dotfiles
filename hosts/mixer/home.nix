{
  imports = [
    ../../modules/home/base
    ../../modules/home/applications.nix
    ../../modules/home/key-remapping.nix
    ../../modules/home/ghostty.nix
    ../../modules/home/zed.nix
    ../../modules/home/vscode.nix
    ../../modules/home/winbox.nix
  ];

  dotfiles.casks = [ "mongodb-compass" ];
}
