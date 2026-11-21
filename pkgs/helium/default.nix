{
  lib,
  appimageTools,
  fetchurl,
  writeShellApplication,
  curl,
  gnugrep,
  gnused,
  jq,
}:

appimageTools.wrapType2 (finalAttrs: {
  pname = "helium";
  version = "0.22.2.1";

  src = fetchurl {
    url = "https://github.com/imputnet/helium-linux/releases/download/${finalAttrs.version}/helium-${finalAttrs.version}-x86_64.AppImage";
    hash = "sha256-8JDIESU/1ovH64lLmCoL4iHRcB937UtT9hRkma+LrgQ=";
  };

  extraInstallCommands = ''
    install -Dm444 ${finalAttrs.contents}/helium.desktop \
      $out/share/applications/helium.desktop
    substituteInPlace $out/share/applications/helium.desktop \
      --replace-fail 'Exec=helium' "Exec=$out/bin/helium"
    install -Dm444 ${finalAttrs.contents}/helium.png \
      $out/share/icons/hicolor/256x256/apps/helium.png
  '';

  passthru.updateScript = writeShellApplication {
    name = "update-helium";
    runtimeInputs = [
      curl
      gnugrep
      gnused
      jq
    ];
    text = ''
      package=pkgs/helium/default.nix
      if [[ ! -f $package ]]; then
        echo "run from the repository root" >&2
        exit 1
      fi

      auth=()
      if [[ -n ''${GITHUB_TOKEN:-} ]]; then
        auth=(-H "Authorization: Bearer $GITHUB_TOKEN")
      fi

      latest=$(curl -fsSL "''${auth[@]}" https://api.github.com/repos/imputnet/helium-linux/releases/latest | jq -er .tag_name)
      if [[ ! $latest =~ ^[0-9]+(\.[0-9]+)+$ ]]; then
        echo "unexpected helium release tag: $latest" >&2
        exit 1
      fi

      current=${lib.escapeShellArg finalAttrs.version}
      if [[ $latest == "$current" ]]; then
        echo "helium is up to date at $current" >&2
        exit 0
      fi

      version_line='^  version = "[^"]*";$'
      hash_line='^    hash = "[^"]*";$'
      for pattern in "$version_line" "$hash_line"; do
        if [[ $(grep -c "$pattern" "$package") != 1 ]]; then
          echo "expected exactly one line matching '$pattern' in $package" >&2
          exit 1
        fi
      done

      url="https://github.com/imputnet/helium-linux/releases/download/$latest/helium-$latest-x86_64.AppImage"
      hash=$(nix store prefetch-file --json --hash-type sha256 "$url" | jq -er .hash)

      updated=$(mktemp)
      trap 'rm -f "$updated"' EXIT
      sed -e "s|$version_line|  version = \"$latest\";|" -e "s|$hash_line|    hash = \"$hash\";|" "$package" >"$updated"
      cat "$updated" >"$package"

      echo "helium $current -> $latest"
    '';
  };

  meta = {
    description = "Private, fast, and honest web browser";
    homepage = "https://helium.computer";
    license = lib.licenses.gpl3;
    mainProgram = "helium";
    platforms = [ "x86_64-linux" ];
  };
})
