{ modules, ... }:
{
  imports = [
    modules.home.default
    modules.home.key-remapping
    modules.home.ghostty
    modules.home.zed
    modules.home.winbox
  ];
}
