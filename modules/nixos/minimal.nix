{ ... }:

{
  imports = [
    ../shared

    ./system/base.nix
  ];

  # The activation flake lives in the root-owned Nix store. Running the
  # evaluator as the calling user makes libgit2 reject that path as unsafe.
  nixos-unified.localPrivilegeMode = "sudo-nixos-rebuild";
}
