{
  inputs,
  lib ? inputs.nixpkgs.lib,
}:
rawInventory:
let
  inventory = import ./resolve-inventory.nix { inherit lib; } rawInventory;
  resolve = class: (inputs.flake-aspects.lib lib).resolve class [ ];
  hosts = lib.mapAttrs (
    _: host:
    let
      pkgs = import inputs.nixpkgs {
        inherit (host) system;
        config.allowUnfree = true;
        overlays = [ inputs.self.overlays.default ];
      };
      accounts = lib.mapAttrs (
        _: account:
        account
        // {
          homeModules =
            map (resolve "homeManager") [
              host.aspect
              inventory.users.${account.userName}.aspect
              account.aspect
            ]
            ++ [
              ../modules/home.nix
              {
                _module.args.dotfilesUnmanaged = host.backend == "unmanaged";
                home = {
                  username = lib.mkForce account.userName;
                  homeDirectory = lib.mkForce account.home.directory;
                  stateVersion = lib.mkForce account.home.stateVersion;
                };
              }
            ];
        }
      ) (lib.filterAttrs (_: a: a.hostName == host.name) inventory.accounts);
      darwin = host.backend == "darwin";
      constructor = if darwin then inputs.nix-darwin.lib.darwinSystem else inputs.nixpkgs.lib.nixosSystem;
    in
    {
      native = constructor {
        specialArgs = { inherit inputs; };
        modules = [
          (resolve host.backend host.aspect)
          (
            if darwin then
              inputs.home-manager.darwinModules.home-manager
            else
              inputs.home-manager.nixosModules.home-manager
          )
          (import ./system-adapter.nix {
            inherit host pkgs;
            accounts = builtins.attrValues accounts;
          })
          { home-manager.extraSpecialArgs = { inherit inputs; }; }
        ]
        ++ lib.concatMap (
          a:
          map (resolve host.backend) [
            inventory.users.${a.userName}.aspect
            a.aspect
          ]
        ) (builtins.attrValues accounts);
      };
      homes = lib.mapAttrs (
        _: a:
        inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = a.homeModules;
          extraSpecialArgs = { inherit inputs; };
        }
      ) accounts;
    }
  ) inventory.hosts;
  native =
    backend:
    lib.mapAttrs (name: _: hosts.${name}.native) (
      lib.filterAttrs (_: host: host.backend == backend) inventory.hosts
    );
in
{
  darwinConfigurations = native "darwin";
  nixosConfigurations = native "nixos";
  homeConfigurations = lib.foldlAttrs (
    result: _: host:
    result // host.homes
  ) { } hosts;
}
