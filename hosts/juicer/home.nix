{
  imports = [
    ../../modules/home/base
    ../../modules/home/applications.nix
    ../../modules/home/discord.nix
    ../../modules/home/firefox.nix
    ../../modules/home/key-remapping.nix
    ../../modules/home/ghostty.nix
    ../../modules/home/zed.nix
    ../../modules/home/xcode
    ../../modules/home/vscode.nix
    ../../modules/home/winbox.nix
  ];

  dotfiles.casks = [
    "cloudflare-warp"
    "ddpm"
    "lm-studio"
    "notion"
    "tableplus"
    "utm"
  ];
}
