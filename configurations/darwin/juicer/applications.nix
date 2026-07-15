{ config, pkgs, ... }:

{
  homebrew = {
    casks = [
      "notion"

      "cloudflare-warp"
    ];
  };

  home-manager.users.${config.system.primaryUser}.home.packages = with pkgs; [
    lmstudio
    utm
  ];
}
