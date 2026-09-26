{ lib, ... }:

{
  # Shared preferences; account modules may override individual keys.
  system.defaults = {
    CustomUserPreferences = {
      "com.apple.desktopservices" = {
        DSDontWriteNetworkStores = lib.mkDefault true;
        DSDontWriteUSBStores = lib.mkDefault true;
      };
    };

    finder = {
      AppleShowAllExtensions = lib.mkDefault true;
      AppleShowAllFiles = lib.mkDefault true;
      CreateDesktop = lib.mkDefault true;
      FXDefaultSearchScope = lib.mkDefault "SCcf";
      FXEnableExtensionChangeWarning = lib.mkDefault false;
      FXPreferredViewStyle = lib.mkDefault "clmv";
      FXRemoveOldTrashItems = lib.mkDefault true;
      ShowExternalHardDrivesOnDesktop = lib.mkDefault true;
      ShowHardDrivesOnDesktop = lib.mkDefault false;
      ShowMountedServersOnDesktop = lib.mkDefault true;
      ShowPathbar = lib.mkDefault true;
      ShowRemovableMediaOnDesktop = lib.mkDefault true;
      ShowStatusBar = lib.mkDefault true;
      _FXShowPosixPathInTitle = lib.mkDefault true;
      _FXSortFoldersFirst = lib.mkDefault true;
      _FXSortFoldersFirstOnDesktop = lib.mkDefault true;
    };
  };
}
