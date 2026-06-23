{
  lib,
  pkgs,
  osConfig ? { },
  ...
}:

let
  enabled = pkgs.stdenv.isDarwin && (osConfig.containerRuntime or null) == "container";
in
{
  config = lib.mkIf enabled {
    xdg.configFile."container/config.toml" = {
      source = ./apple-container.toml;

      # The container service reads config.toml only at startup.
      onChange = ''
        ${pkgs.apple-container}/bin/container system stop || true
        ${pkgs.apple-container}/bin/container system start --enable-kernel-install || true
      '';
    };
  };
}
