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
      checkPhase = ''
        runHook preCheck
        go test -v ./...
        bash ./test/direnv-test.bash
        runHook postCheck
      '';
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
