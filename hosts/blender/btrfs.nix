{ config, ... }:

{
  services.snapper = {
    persistentTimer = true;

    configs.home = {
      SUBVOLUME = "/home";
      ALLOW_USERS = [ config.dotfiles.primaryUser ];
      TIMELINE_CREATE = true;
      TIMELINE_CLEANUP = true;
      TIMELINE_LIMIT_HOURLY = 24;
      TIMELINE_LIMIT_DAILY = 7;
      TIMELINE_LIMIT_WEEKLY = 4;
      TIMELINE_LIMIT_MONTHLY = 3;
      TIMELINE_LIMIT_QUARTERLY = 0;
      TIMELINE_LIMIT_YEARLY = 0;
    };
  };

  services.btrfs.autoScrub.enable = true;
}
