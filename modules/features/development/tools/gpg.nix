{ lib, pkgs, ... }:

{
  programs.gpg = {
    enable = true;

    settings = {
      keyid-format = "long";
      with-fingerprint = true;
    };
  };

  services.gpg-agent = {
    enable = true;
    enableZshIntegration = true;
    defaultCacheTtl = 28800;
    maxCacheTtl = 86400;
    pinentry.package =
      # Native authentication helper: the explicit exception to cask-owned GUI apps.
      if pkgs.stdenv.hostPlatform.isDarwin then pkgs.pinentry_mac else pkgs.pinentry-curses;
  };

  # GnuPG starts its agent on demand using ~/.gnupg/S.gpg-agent. The Darwin
  # supervised launchd job uses a different socket and repeatedly exits with 2.
  # Retain the shared agent/pinentry configuration without that duplicate job.
  launchd.agents.gpg-agent.enable = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin (lib.mkForce false);
}
