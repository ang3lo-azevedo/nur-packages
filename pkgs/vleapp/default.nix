{
  lib,
  stdenvNoCC,
  python3,
  makeWrapper,
  copyDesktopItems,
  makeDesktopItem,
  callPackage,
  pyliblzfse,
}: let
  sources = callPackage ../../_sources/generated.nix {};
  writable-copies = callPackage ../leapp-common {};

  python = python3.withPackages (ps:
    with ps; [
      writable-copies
      beautifulsoup4
      ijson
      openpyxl
      packaging
      pillow
      pycryptodome
      pyliblzfse
      pytz
      simplekml
      tkinter
      xmltodict
      zstandard
    ]);
in
  stdenvNoCC.mkDerivation {
    pname = "vleapp";
    version = lib.removePrefix "v" sources.vleapp.version;

    src = sources.vleapp.src;

    nativeBuildInputs = [
      makeWrapper
      copyDesktopItems
    ];

    dontBuild = true;

    # The GUI looks for its assets under the working directory, which only
    # works when it is started from a source checkout
    postPatch = ''
      substituteInPlace vleappGUI.py \
        --replace-fail 'base_path = os.path.abspath(".")' 'base_path = os.path.dirname(os.path.abspath(__file__))'
    '';

    desktopItems = [
      (makeDesktopItem {
        name = "vleapp";
        desktopName = "VLEAPP";
        comment = "Parse vehicle extractions into a forensic report";
        exec = "vleapp-gui";
        icon = "vleapp";
        categories = ["System" "Utility"];
      })
    ];

    # It has no installer and finds its artifact plugins and report assets
    # relative to its own scripts, so the tree is kept whole.
    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/vleapp $out/bin
      install -Dm444 assets/icon.png $out/share/icons/hicolor/256x256/apps/vleapp.png
      cp -r vleapp.py vleappGUI.py assets leapp_functions scripts $out/share/vleapp/
      makeWrapper ${python}/bin/python $out/bin/vleapp --add-flags $out/share/vleapp/vleapp.py
      makeWrapper ${python}/bin/python $out/bin/vleapp-gui --add-flags $out/share/vleapp/vleappGUI.py
      runHook postInstall
    '';

    meta = with lib; {
      description = "Vehicle Logs, Events, And Properties Parser";
      homepage = "https://github.com/abrignoni/VLEAPP";
      license = licenses.mit;
      maintainers = [];
      mainProgram = "vleapp";
      platforms = platforms.linux;
    };
  }
