{
  lib,
  stdenvNoCC,
  python3,
  makeWrapper,
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

    nativeBuildInputs = [makeWrapper];

    dontBuild = true;

    # It has no installer and finds its artifact plugins and report assets
    # relative to its own scripts, so the tree is kept whole.
    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/vleapp $out/bin
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
