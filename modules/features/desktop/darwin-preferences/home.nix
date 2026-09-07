{ lib, pkgs, ... }:
{
  imports = [
    ./defaults.nix
    ./dock.nix
    ./finder.nix
    ./input.nix
  ];
  config = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    targets.darwin.defaults."com.apple.screensaver" = {
      askForPassword = true;
      askForPasswordDelay = 0;
    };
    home.activation.restartDock = lib.hm.dag.entryAfter [ "setDarwinDefaults" ] ''
      run /usr/bin/killall Dock || true
    '';
  };
}
