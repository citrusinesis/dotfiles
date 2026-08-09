{
  container,
  fetchurl,
  nix-update-script,
  stdenv,
}:

container.overrideAttrs (old: rec {
  version = "1.2.2";
  src = fetchurl {
    url = "https://github.com/apple/container/releases/download/${version}/container-${version}-installer-signed.pkg";
    hash = "sha256-9MfnP3IDclo1Emdt/Z7GxqmKNwk7b9ShsP3PyyJ+IRg=";
  };

  postInstall = (old.postInstall or "") + ''
    # These upstream helpers bypass the pinned package and mutate /usr/local.
    rm -f "$out/bin/update-container.sh" "$out/bin/uninstall-container.sh"
  '';

  meta = (old.meta or { }) // {
    platforms = [ "aarch64-darwin" ];
  };

  passthru = old.passthru // {
    updateScript = nix-update-script {
      attrPath = "legacyPackages.${stdenv.hostPlatform.system}.apple-container";
      extraArgs = [
        "--flake"
        "--override-filename=packages/apple-container/package.nix"
        "--use-github-releases"
        "--system=aarch64-darwin"
      ];
    };
  };
})
