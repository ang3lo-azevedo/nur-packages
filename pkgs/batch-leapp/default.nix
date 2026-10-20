{
  lib,
  stdenvNoCC,
  python3,
  makeWrapper,
  copyDesktopItems,
  imagemagick,
  makeDesktopItem,
  callPackage,
}: let
  sources = callPackage ../../_sources/generated.nix {};
  python = python3.withPackages (ps: [ps.tkinter]);
in
  stdenvNoCC.mkDerivation {
    pname = "batch-leapp";
    version = lib.removePrefix "v" sources.batch-leapp.version;

    src = sources.batch-leapp.src;

    nativeBuildInputs = [
      makeWrapper
      copyDesktopItems
      imagemagick
    ];

    dontBuild = true;

    desktopItems = [
      (makeDesktopItem {
        name = "batch-leapp";
        desktopName = "Batch-LEAPP";
        comment = "Run a LEAPP tool over a folder of extractions";
        exec = "batch-leapp-gui";
        icon = "batch-leapp";
        categories = ["System" "Utility"];
      })
    ];

    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/batch-leapp $out/bin
      mkdir -p $out/share/icons/hicolor/256x256/apps
      magick docs/icon.png -resize 256x256 $out/share/icons/hicolor/256x256/apps/batch-leapp.png
      cp batch_leapp.py batch_leapp_gui.py batch_coverage.py $out/share/batch-leapp/
      makeWrapper ${python}/bin/python $out/bin/batch-leapp --add-flags $out/share/batch-leapp/batch_leapp.py
      makeWrapper ${python}/bin/python $out/bin/batch-leapp-gui --add-flags $out/share/batch-leapp/batch_leapp_gui.py
      runHook postInstall
    '';

    meta = with lib; {
      description = "Run any LEAPP tool over a folder of extractions with one report index";
      homepage = "https://github.com/abrignoni/batch-leapp";
      # The repository publishes no licence
      license = licenses.unfree;
      maintainers = [];
      mainProgram = "batch-leapp";
      platforms = platforms.linux;
    };
  }
