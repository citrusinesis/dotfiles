{ modules, ... }:
{
  imports = [
    modules.home.default
    modules.home.ghostty
    modules.home.hyprland
  ];
}
