{
  inputs,
  lib,
  pkgs,
  ...
}:
{
  imports = [ inputs.paneru.homeModules.paneru ];

  services.paneru = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    enable = true;
    # TOML alone is sufficient; avoid loading a separate Lua configuration.
    luaConfig.enable = false;
    settings = lib.mkDefault (import ./settings.nix);
  };
}
