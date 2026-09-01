{
  lib,
  stdenv,
  makeWrapper,
  chromium,
  chromedriver,
  python312,
  pkgs,
}: let
  sources = pkgs.callPackage ../../_sources/generated.nix {};
  pythonEnv = python312.withPackages (ps:
    with ps; [
      selenium
      tkinter
      requests
      beautifulsoup4
    ]);
in
  stdenv.mkDerivation {
    pname = "ist-fenix-auto-enroller";
    version = sources.ist-fenix-auto-enroller.version;
    src = sources.ist-fenix-auto-enroller.src;

    nativeBuildInputs = [makeWrapper pkgs.copyDesktopItems];

    desktopItems = [
      (pkgs.makeDesktopItem {
        name = "ist-fenix-auto-enroller";
        exec = "ist-fenix-auto-enroller";
        desktopName = "IST Fenix Auto-Enroller";
        comment = "Automatically enroll in IST Fenix shifts";
        categories = ["Utility"];
      })
    ];

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall

      appdir="$out/share/ist-fenix-auto-enroller"
      mkdir -p "$appdir"
      cp -r main.py src "$appdir"/

      makeWrapper ${pythonEnv}/bin/python "$out/bin/ist-fenix-auto-enroller" \
        --add-flags "$appdir/main.py" \
        --set CHROME_BIN ${chromium}/bin/chromium \
        --set CHROMEDRIVER_PATH ${chromedriver}/bin/chromedriver \
        --prefix PATH : ${lib.makeBinPath [chromium chromedriver]}

      runHook postInstall
    '';

    meta = {
      description = "Automatically enroll in IST Fénix shifts";
      homepage = "https://github.com/ang3lo-azevedo/ist-fenix-auto-enroller";
      license = lib.licenses.mit;
      mainProgram = "ist-fenix-auto-enroller";
      platforms = lib.platforms.linux;
    };
  }
