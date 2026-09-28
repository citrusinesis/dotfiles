{ inputs, lib, ... }:
let
  mkHost = import ../lib/mk-host.nix { inherit inputs lib; };

  # Each host is configured by hosts/<name>/default.nix (system) and
  # hosts/<name>/home.nix (its user's Home).
  hosts = {
    juicer = {
      system = "aarch64-darwin";
      user = "citrus";
      stateVersion = "25.11";
    };
    mixer = {
      system = "aarch64-darwin";
      user = "citrus";
      stateVersion = "25.11";
    };
    blender = {
      system = "x86_64-linux";
      user = "citrus";
      stateVersion = "25.11";
    };
    ws-jh-song = {
      system = "x86_64-linux";
      user = "jh-song";
      stateVersion = "25.11";
    };
  };

  built = lib.mapAttrs (name: host: mkHost (host // { inherit name; })) hosts;
  systemsOn =
    suffix:
    lib.mapAttrs (name: _: built.${name}.system) (
      lib.filterAttrs (_: host: lib.hasSuffix suffix host.system) hosts
    );
in
{
  flake = {
    darwinConfigurations = systemsOn "-darwin";
    nixosConfigurations = systemsOn "-linux";
    homeConfigurations = lib.mapAttrs' (
      name: host: lib.nameValuePair "${host.user}@${name}" built.${name}.home
    ) hosts;
  };

  # Host table for policy checks.
  _module.args.hosts = hosts;
}
