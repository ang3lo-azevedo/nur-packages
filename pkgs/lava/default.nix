{
  lib,
  appimageTools,
  callPackage,
}: let
  sources = callPackage ../../_sources/generated.nix {};
  pname = "lava";
  version = lib.removePrefix "v" sources.lava.version;
  src = sources.lava.src;
  appimageContents = appimageTools.extractType2 {inherit pname version src;};
in
  appimageTools.wrapType2 {
    inherit pname version src;

    extraInstallCommands = ''
      install -Dm444 ${appimageContents}/lava.desktop -t $out/share/applications
      substituteInPlace $out/share/applications/lava.desktop \
        --replace-fail 'Exec=AppRun --no-sandbox' 'Exec=lava'
      cp -r ${appimageContents}/usr/share/icons $out/share
    '';

    meta = with lib; {
      description = "LEAPP Artifact Viewer App for reviewing LEAPP reports";
      homepage = "https://github.com/leapps-org/LAVA-releases";
      # Freeware EULA that forbids redistribution, so it stays out of the binary cache
      license = licenses.unfree;
      sourceProvenance = with sourceTypes; [binaryNativeCode];
      maintainers = [];
      mainProgram = "lava";
      platforms = ["x86_64-linux"];
    };
  }
