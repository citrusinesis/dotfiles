{
  default_workspaces = 4;

  options = {
    focus_follows_mouse = false;
    mouse_follows_focus = false;
    animation_speed = 12.0;
    auto_center = false;
    preset_column_widths = [
      0.33
      0.5
      0.7
      1.0
    ];
    preset_stack_heights = [
      0.25
      0.5
      0.75
    ];
    window_resize_cycle = false;
  };

  padding = {
    top = 8;
    bottom = 8;
    left = 8;
    right = 8;
  };

  swipe = {
    continuous = false;
    # Native macOS gestures use three fingers; reserve four for Paneru.
    gesture = {
      fingers_count = 4;
      direction = "Natural";
      vertical = true;
    };
    scroll = {
      modifier = "alt";
      vertical_modifier = "shift";
    };
  };

  windows.default = {
    title = ".*";
    width = 0.7;
  };

  bindings = {
    window_focus_west = "alt - h";
    window_focus_south = "alt - j";
    window_focus_north = "alt - k";
    window_focus_east = "alt - l";
    window_swap_west = "alt + shift - h";
    window_swap_south = "alt + shift - j";
    window_swap_north = "alt + shift - k";
    window_swap_east = "alt + shift - l";

    window_virtualnum_1 = "alt - 1";
    window_virtualnum_2 = "alt - 2";
    window_virtualnum_3 = "alt - 3";
    window_virtualnum_4 = "alt - 4";
    window_virtualsendnum_1 = "alt + shift - 1";
    window_virtualsendnum_2 = "alt + shift - 2";
    window_virtualsendnum_3 = "alt + shift - 3";
    window_virtualsendnum_4 = "alt + shift - 4";

    window_manage = "alt + shift - space";
    window_fullwidth = "alt - f";
    window_center = "alt - c";
    window_stack = "alt - comma";
    window_unstack = "alt - slash";
    window_equalize = "alt + shift - e";
    window_resize = "alt + shift - equal";
    window_shrink = "alt + shift - minus";
    window_vertical_grow = "alt + ctrl - equal";
    window_vertical_shrink = "alt + ctrl - minus";
    restart = "alt + ctrl - r";
    quit = "alt + ctrl - q";
  };
}
