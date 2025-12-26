{ ... }: {
  programs.kitty = {
    enable = true;

    font = {
      name = "Hack Nerd Font Mono";
      size = 11;
    };

    themeFile = "Catppuccin-Macchiato";
    
    settings = {
      cursor_shape = "block";
      cursor_beam_thickness = "1.5";
      cursor_blink_interval = "0"; 

      scrollback_lines = 10000;
      scrollback_pager_history_size = 100;

      tab_bar_style = "powerline";
      tab_bar_background = "#181825";

      window_padding_width = "4";
      background_opacity = "0.9";

      enable_audio_bell = "no";
      visual_bell_duration = "0.1";

      repaint_delay = 10; 
      input_delay = 3;  

      "map ctrl+shift+enter" = "new_window";
      "map ctrl+shift+t" = "new_tab";
      "map ctrl+shift+up" = "scroll_line_up";
      "map ctrl+shift+down" = "scroll_line_down";
      "map ctrl+shift+right" = "next_window";
      "map ctrl+shift+left" = "previous_window";
    };
  };
}