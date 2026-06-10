{ flake, ... }:

{
  imports = [
    flake.inputs.self.darwinModules.default
    ./applications.nix
  ];

  networking.hostName = "juicer";

  containerRuntime = "container";
}
