{ ... }:

{
  programs.bat = {
    enable = true;
    config = {
      theme = "Catppuccin Mocha";
      pager = "less -FR";
      style = "numbers,changes,header";
    };
  };
}
