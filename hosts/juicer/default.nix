{ modules, ... }:
{
  imports = [
    modules.darwin.default
    modules.darwin.apple-container
    modules.darwin.applications
    modules.system.fonts
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
