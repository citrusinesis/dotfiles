{ ... }:

{
  programs.btop = {
    enable = true;
    settings = {
      color_theme = "catppuccin_mocha";
      vim_keys = true;
      rounded_corners = true;
      update_ms = 1000;
    };
  };
}
