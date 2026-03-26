{ pkgs, ... }:

{
  home.packages = with pkgs; [
    lorri
  ];

  programs.direnv = {
    enable = true;
    package = pkgs.direnv.overrideAttrs (old: {
      env = (old.env or { }) // {
        CGO_ENABLED = "1";
      };
    });
    nix-direnv.enable = true;

    config = {
      global = {
        load_dotenv = true;
        strict_env = true;
        warn_timeout = "5m";
      };
    };
  };
}
