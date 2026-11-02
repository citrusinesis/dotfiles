{ ... }:

{
  # Send the existing Hangul toggle directly; evdev F18 becomes XF86Launch9
  # under the default XKB map, so it cannot match an fcitx5 F18 shortcut.
  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = [ "*" ];
      settings.main.capslock = "hangeul";
    };
  };
}
