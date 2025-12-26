# Darwin Workstation Profile
# macOS development machine with Homebrew GUI apps
{ ... }:

{
  imports = [
    ../modules/nix.nix
    ../modules/fonts.nix
    ../modules/darwin/base.nix
    ../modules/darwin/system-defaults.nix
    ../modules/darwin/homebrew.nix
  ];
}
