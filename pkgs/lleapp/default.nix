{
  lib,
  stdenvNoCC,
  python3,
  makeWrapper,
  copyDesktopItems,
  imagemagick,
  makeDesktopItem,
  callPackage,
  apachelogs,
  freesimplegui,
  utmp,
}: let
  sources = callPackage ../../_sources/generated.nix {};
  writable-copies = callPackage ../leapp-common {};

  # blackboxprotobuf is in upstream's requirements but nothing imports it
  python = python3.withPackages (ps:
    with ps; [
      writable-copies
      apachelogs
      beautifulsoup4
      freesimplegui
      pycryptodome
      python-crontab
      simplekml
      utmp
      xmltodict
    ]);
in
  stdenvNoCC.mkDerivation {
    pname = "lleapp";
    version = "1.2-unstable-${sources.lleapp.date}";

    src = sources.lleapp.src;

    nativeBuildInputs = [
      makeWrapper
      copyDesktopItems
      imagemagick
    ];

    dontBuild = true;

    desktopItems = [
      (makeDesktopItem {
        name = "lleapp";
        desktopName = "lLEAPP";
        comment = "Parse Linux extractions into a forensic report";
        exec = "lleapp-gui";
        icon = "lleapp";
        categories = ["System" "Utility"];
      })
    ];

    # PySimpleGUI 4 was pulled from PyPI when it went proprietary.
    # The log artifacts search var/logs/, which is not where Linux keeps them
    postPatch = ''
      substituteInPlace lleappGUI.py --replace-fail "import PySimpleGUI as sg" "import FreeSimpleGUI as sg"
      substituteInPlace scripts/artifacts/{aptHistory,authLog,apacheLogFiles,btmp,wtmp}.py \
        --replace-fail "**/var/logs/" "**/var/log*/"
    '';

    # It has no installer and finds its artifact plugins and report assets
    # relative to its own scripts, so the tree is kept whole.
    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/lleapp $out/bin
      mkdir -p $out/share/icons/hicolor/256x256/apps
      magick scripts/logo.jpg -resize 256x256 $out/share/icons/hicolor/256x256/apps/lleapp.png
      cp -r lleapp.py lleappGUI.py plugin_loader.py lib scripts $out/share/lleapp/
      makeWrapper ${python}/bin/python $out/bin/lleapp --add-flags $out/share/lleapp/lleapp.py
      makeWrapper ${python}/bin/python $out/bin/lleapp-gui --add-flags $out/share/lleapp/lleappGUI.py
      runHook postInstall
    '';

    meta = with lib; {
      description = "Linux Logs, Events, Application Program Parser";
      homepage = "https://github.com/markmckinnon/lLeapp";
      license = licenses.asl20;
      maintainers = [];
      mainProgram = "lleapp";
      platforms = platforms.linux;
    };
  }
