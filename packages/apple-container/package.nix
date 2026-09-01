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
    rm -f "$out/bin/update-container.sh" "$out/bin/uninstall-container.sh"
  '';

  postFixup = (old.postFixup or "") + ''
    for resource in init create-user.sh; do
      script="$out/libexec/container/plugins/machine-apiserver/resources/$resource"
      sed -i '1s|^#!.*|#!/bin/sh|' "$script"
    done
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
