{ ... }:

{
  xdg.configFile."ghostty/config" = {
    force = true;

    text = ''
      theme = Catppuccin Mocha

      font-family = "Hack Nerd Font"
      font-size = 14

      shell-integration = zsh

      cursor-style = block
      cursor-style-blink = false

      window-padding-x = 12
      window-padding-y = 4
    '';
  };

}
