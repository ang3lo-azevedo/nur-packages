{
  lib,
  stdenv,
  python3,
  callPackage,
  makeWrapper,
  copyDesktopItems,
  makeDesktopItem,
}: let
  sources = callPackage ../../_sources/generated.nix {};

  pythonEnv = python3.withPackages (ps:
    with ps; [
      pillow
      tkinter
    ]);
in
  stdenv.mkDerivation {
    pname = "nsp-box";
    version = sources.nsp-box.version;

    src = sources.nsp-box.src;

    nativeBuildInputs = [makeWrapper copyDesktopItems];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/nsp-box $out/bin
      # The modules import each other flatly (import engine, ...) and resolve
      # assets relative to their own file, so the whole src tree lives together.
      cp -r src/. $out/share/nsp-box/

      install -Dm644 src/assets/icons/app.png $out/share/icons/hicolor/256x256/apps/nsp-box.png

      makeWrapper ${pythonEnv}/bin/python $out/bin/nsp-box \
        --add-flags "$out/share/nsp-box/app.py" \
        --prefix PYTHONPATH : $out/share/nsp-box

      runHook postInstall
    '';

    desktopItems = [
      (makeDesktopItem {
        name = "nsp-box";
        exec = "nsp-box";
        icon = "nsp-box";
        desktopName = "NSP Box";
        comment = "Switch 2 game packager for lawfully obtained dumps";
        categories = ["Game" "Utility"];
      })
    ];

    meta = with lib; {
      description = "NSP Box: a Switch 2 game packager for lawfully obtained game snapshots and extracted DLC";
      homepage = "https://github.com/smarkyie/NSP-Box";
      license = licenses.mit;
      maintainers = [];
      mainProgram = "nsp-box";
      platforms = platforms.all;
    };
  }
