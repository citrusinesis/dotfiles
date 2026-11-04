{
  lib,
  appimageTools,
  fetchurl,
}:

appimageTools.wrapType2 (finalAttrs: {
  pname = "helium";
  version = "0.20.3.1";

  src = fetchurl {
    url = "https://github.com/imputnet/helium-linux/releases/download/${finalAttrs.version}/helium-${finalAttrs.version}-x86_64.AppImage";
    hash = "sha256-H69Thkj+FKHqkuMlyxI4rojEeGZsteY9DSrxcP5MoDc=";
  };

  extraInstallCommands = ''
    install -Dm444 ${finalAttrs.contents}/helium.desktop \
      $out/share/applications/helium.desktop
    substituteInPlace $out/share/applications/helium.desktop \
      --replace-fail 'Exec=helium' "Exec=$out/bin/helium"
    install -Dm444 ${finalAttrs.contents}/helium.png \
      $out/share/icons/hicolor/256x256/apps/helium.png
  '';

  meta = {
    description = "Private, fast, and honest web browser";
    homepage = "https://helium.computer";
    license = lib.licenses.gpl3;
    mainProgram = "helium";
    platforms = [ "x86_64-linux" ];
  };
})
