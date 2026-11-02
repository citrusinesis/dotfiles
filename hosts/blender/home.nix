{ modules, ... }:
{
  imports = [
    modules.home.default
    modules.home.ghostty
    modules.home.firefox
    modules.home.niri
  ];

  programs.firefox.profiles.default.settings."media.hardware-video-decoding.force-enabled" = true;
}
