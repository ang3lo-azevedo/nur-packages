{
  lib,
  stdenvNoCC,
  python3,
  makeWrapper,
  callPackage,
  bencoding,
  pyliblzfse,
}: let
  sources = callPackage ../../_sources/generated.nix {};
  writable-copies = callPackage ../leapp-common {};

  python = python3.withPackages (ps:
    with ps; [
      writable-copies
      beautifulsoup4
      bencoding
      ijson
      mammoth
      openpyxl
      packaging
      pdfminer-six
      pillow
      pillow-heif
      pycryptodome
      pyliblzfse
      pypdf
      pytz
      simplekml
      tkinter
      xmltodict
      zstandard
    ]);
in
  stdenvNoCC.mkDerivation {
    pname = "rleapp";
    version = lib.removePrefix "v" sources.rleapp.version;

    src = sources.rleapp.src;

    nativeBuildInputs = [makeWrapper];

    dontBuild = true;

    # It has no installer and finds its artifact plugins and report assets
    # relative to its own scripts, so the tree is kept whole.
    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/rleapp $out/bin
      cp -r rleapp.py rleappGUI.py assets leapp_functions scripts $out/share/rleapp/
      makeWrapper ${python}/bin/python $out/bin/rleapp --add-flags $out/share/rleapp/rleapp.py
      makeWrapper ${python}/bin/python $out/bin/rleapp-gui --add-flags $out/share/rleapp/rleappGUI.py
      runHook postInstall
    '';

    meta = with lib; {
      description = "Returns Logs, Events, And Properties Parser for provider data returns";
      homepage = "https://github.com/abrignoni/RLEAPP";
      license = licenses.mit;
      maintainers = [];
      mainProgram = "rleapp";
      platforms = platforms.linux;
    };
  }
