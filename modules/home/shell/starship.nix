{ ... }:

{
  programs.starship = {
    enable = true;

    enableZshIntegration = true;
    enableBashIntegration = true;

    settings = fromTOML (builtins.readFile ./starship.toml);
  };
}
