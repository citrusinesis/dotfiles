{ modules, ... }:
{
  imports = [
    modules.home.default
    modules.home.ghostty
    modules.home.firefox
    modules.home.niri
  ];
}
