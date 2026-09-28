{ lib }:
# Exposes modules/<class>/<name>(.nix) as `modules.<class>.<name>`.
# `modules.<class>.default` is what every host of that class imports.
let
  entries =
    dir:
    lib.mapAttrs' (name: _: lib.nameValuePair (lib.removeSuffix ".nix" name) (dir + "/${name}")) (
      lib.filterAttrs (name: type: type == "directory" || lib.hasSuffix ".nix" name) (
        builtins.readDir dir
      )
    );
in
lib.mapAttrs (_: entries) (
  lib.mapAttrs (name: _: ../modules + "/${name}") (
    lib.filterAttrs (_: type: type == "directory") (builtins.readDir ../modules)
  )
)
