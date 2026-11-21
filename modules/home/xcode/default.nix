{ lib, pkgs, ... }:
let
  userData = "Library/Developer/Xcode/UserData";
in
{
  home.file = {
    "${userData}/FontAndColorThemes/Catppuccin Mocha.xccolortheme".source =
      pkgs.callPackage ./theme.nix
        { };
    "${userData}/KeyBindings/Zed.idekeybindings".text = import ./keybindings.nix { inherit lib; };
  };
}
