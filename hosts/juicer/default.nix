{
  imports = [
    ../../modules/darwin
    ../../modules/darwin/apple-container.nix
    ../../modules/darwin/applications.nix
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

  homebrew.casks = [
    "notion"

    "cloudflare-warp"
    "lm-studio"
    "utm"
  ];
}
