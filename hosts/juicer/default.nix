{
  imports = [
    ../../modules/darwin
    ../../modules/darwin/apple-container.nix
    ../../modules/darwin/applications.nix
    ../../modules/darwin/xcode.nix
    ../../modules/system/fonts
    ./nix-store.nix
    ./preferences.nix
  ];

  time.timeZone = "Asia/Seoul";

  # Restrict the ports without enabling SSH or Screen Sharing services.
  pf = {
    screen-sharing = {
      enable = true;
      high-performance = true;
    };
    ssh.enable = true;
  };

  homebrew.brews = [ "mole" ];

  homebrew.casks = [
    "notion"

    "cloudflare-warp"
    "ddpm"
    "discord"
    "firefox"
    "lm-studio"
    "tableplus"
    "utm"
  ];
}
