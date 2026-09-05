{ ... }:

{
  system.defaults = {
    finder = {
      # Display
      _FXShowPosixPathInTitle = true;
      _FXSortFoldersFirst = true;
      _FXSortFoldersFirstOnDesktop = true;
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;
      FXPreferredViewStyle = "clmv";
      ShowPathbar = true;
      ShowStatusBar = true;

      # Search & warnings
      FXDefaultSearchScope = "SCcf"; # SCcf=current folder | SCsp=previous scope | SCev=entire Mac
      FXEnableExtensionChangeWarning = false;

      # Desktop
      CreateDesktop = true;
      ShowExternalHardDrivesOnDesktop = true;
      ShowHardDrivesOnDesktop = false;
      ShowMountedServersOnDesktop = true;
      ShowRemovableMediaOnDesktop = true;

      # Behavior
      FXRemoveOldTrashItems = true;
      QuitMenuItem = true;
    };

    # Prevent .DS_Store on network and USB volumes
    CustomUserPreferences."com.apple.desktopservices" = {
      DSDontWriteNetworkStores = true;
      DSDontWriteUSBStores = true;
    };
  };
}
