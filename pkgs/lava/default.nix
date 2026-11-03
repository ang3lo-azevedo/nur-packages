{
  lib,
  appimageTools,
  callPackage,
  imagemagick,
}: let
  sources = callPackage ../../_sources/generated.nix {};
  pname = "lava";
  version = lib.removePrefix "v" sources.lava.version;
  src = sources.lava.src;
  appimageContents = appimageTools.extract {inherit pname version src;};
in
  appimageTools.wrapType2 {
    inherit pname version src;

    extraInstallCommands = ''
      install -Dm444 ${appimageContents}/lava.desktop -t $out/share/applications
      substituteInPlace $out/share/applications/lava.desktop \
        --replace-fail 'Exec=AppRun --no-sandbox' 'Exec=lava'
      # The AppImage ships the icon only at 1024x1024, a size hicolor's index.theme
      # does not list, so themed lookup (fuzzel, etc.) never finds it. Resize into a
      # listed size so the launcher resolves Icon=lava.
      ${imagemagick}/bin/magick \
        ${appimageContents}/usr/share/icons/hicolor/1024x1024/apps/lava.png \
        -resize 256x256 lava.png
      install -Dm444 lava.png $out/share/icons/hicolor/256x256/apps/lava.png
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
