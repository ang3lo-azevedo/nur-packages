{
  lib,
  stdenvNoCC,
  python3,
  makeWrapper,
  copyDesktopItems,
  imagemagick,
  makeDesktopItem,
  callPackage,
  freesimplegui,
}: let
  sources = callPackage ../../_sources/generated.nix {};
  writable-copies = callPackage ../leapp-common {};

  # blackboxprotobuf is in upstream's requirements but nothing imports it
  python = python3.withPackages (ps:
    with ps; [
      writable-copies
      beautifulsoup4
      freesimplegui
      pycryptodome
      simplekml
      xmltodict
    ]);
in
  stdenvNoCC.mkDerivation {
    pname = "cleapp";
    version = "1.0-unstable-${sources.cleapp.date}";

    src = sources.cleapp.src;

    nativeBuildInputs = [
      makeWrapper
      copyDesktopItems
      imagemagick
    ];

    dontBuild = true;

    desktopItems = [
      (makeDesktopItem {
        name = "cleapp";
        desktopName = "cLEAPP";
        comment = "Parse ChromeOS extractions into a forensic report";
        exec = "cleapp-gui";
        icon = "cleapp";
        categories = ["System" "Utility"];
      })
    ];

    # PySimpleGUI 4 was pulled from PyPI when it went proprietary
    postPatch = ''
      substituteInPlace cleappGUI.py --replace-fail "import PySimpleGUI as sg" "import FreeSimpleGUI as sg"
    '';

    # It has no installer and finds its artifact plugins and report assets
    # relative to its own scripts, so the tree is kept whole.
    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/cleapp $out/bin
      mkdir -p $out/share/icons/hicolor/256x256/apps
      magick scripts/logo.jpg -resize 256x256 $out/share/icons/hicolor/256x256/apps/cleapp.png
      cp -r cleapp.py cleappGUI.py scripts $out/share/cleapp/
      makeWrapper ${python}/bin/python $out/bin/cleapp --add-flags $out/share/cleapp/cleapp.py
      makeWrapper ${python}/bin/python $out/bin/cleapp-gui --add-flags $out/share/cleapp/cleappGUI.py
      runHook postInstall
    '';

    meta = with lib; {
      description = "ChromeOS Logs, Events, And Protobuf Parser";
      homepage = "https://github.com/markmckinnon/cLeapp";
      license = licenses.asl20;
      maintainers = [];
      mainProgram = "cleapp";
      platforms = platforms.linux;
    };
  }
