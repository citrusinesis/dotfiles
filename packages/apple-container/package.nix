{
  container,
  fetchurl,
  nix-update-script,
  stdenv,
}:

container.overrideAttrs (old: rec {
  version = "1.1.0";
  src = fetchurl {
    url = "https://github.com/apple/container/releases/download/${version}/container-${version}-installer-signed.pkg";
    hash = "sha256-DKHEKiJpwlV++x2CsbOKxVPmo6PaGxF5xDm87h59ZxQ=";
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
