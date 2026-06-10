{
  lib,
  stdenvNoCC,
  fetchurl,
  xar,
  cpio,
}:

let
  source = lib.importJSON ./source.json;
in
stdenvNoCC.mkDerivation {
  pname = "apple-container";
  inherit (source) version;

  src = fetchurl { inherit (source) url hash; };

  nativeBuildInputs = [
    xar
    cpio
  ];

  unpackPhase = ''
    runHook preUnpack

    xar -xf $src
    zcat Payload | cpio -idm

    runHook postUnpack
  '';

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -R bin libexec $out/
    rm $out/bin/uninstall-container.sh $out/bin/update-container.sh

    runHook postInstall
  '';

  # Binaries are signed by Apple with virtualization entitlements;
  # stripping or patching them would invalidate the signature.
  dontFixup = true;

  meta = {
    description = "Tool for creating and running Linux containers using lightweight virtual machines on macOS";
    homepage = "https://github.com/apple/container";
    license = lib.licenses.asl20;
    sourceProvenance = [ lib.sourceProvenances.binaryNativeCode ];
    platforms = [ "aarch64-darwin" ];
    mainProgram = "container";
  };
}
