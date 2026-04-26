{ ... }:

{
  programs.starship = {
    enable = true;

    enableZshIntegration = true;

    settings = fromTOML (builtins.readFile ./starship.toml);
  };
}
