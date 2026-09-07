{ lib, pkgs, ... }:

{
  config = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    targets.darwin.defaults = {
      "com.apple.finder" = {
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
      "com.apple.desktopservices" = {
        DSDontWriteNetworkStores = true;
        DSDontWriteUSBStores = true;
      };
    };
  };
}
