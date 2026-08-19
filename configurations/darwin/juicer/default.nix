{ config, flake, ... }:

{
  imports = [
    flake.inputs.self.darwinModules.default
    ./applications.nix
  ];

  networking.hostName = "juicer";

  home-manager.users.${config.system.primaryUser}.dotfiles.home.appleContainer.enable = true;
}
