{ inputs, lib, ... }:
let
  mkHost = import ../lib/mk-host.nix { inherit inputs lib; };

  # Each host is configured by hosts/<name>/default.nix (system) and
  # hosts/<name>/home.nix (its user's Home).
  hosts = {
    blender = {
      system = "x86_64-linux";
      user = "citrus";
      stateVersion = "26.11";
    };
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
    ws-jh-song = {
      system = "x86_64-linux";
      user = "jh-song";
      stateVersion = "25.11";
    };
  };

  systemsOn =
    suffix:
    lib.mapAttrs (name: host: mkHost (host // { inherit name; })) (
      lib.filterAttrs (_: host: lib.hasSuffix suffix host.system) hosts
    );
in
{
  flake = {
    darwinConfigurations = systemsOn "-darwin";
    nixosConfigurations = systemsOn "-linux";
  };
}
