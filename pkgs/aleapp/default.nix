{
  lib,
  stdenvNoCC,
  python3,
  makeWrapper,
  callPackage,
  bencoding,
  mister-skinnylegs,
  pyliblzfse,
}: let
  sources = callPackage ../../_sources/generated.nix {};
  writable-copies = callPackage ../leapp-common {};

  # blackboxprotobuf is left out on purpose: upstream runs its own vendored copy
  python = python3.withPackages (ps:
    with ps; [
      writable-copies
      bcrypt
      beautifulsoup4
      bencoding
      fitdecode
      folium
      packaging
      pillow
      polyline
      protobuf
      sqlcipher3
      pycryptodome
      pyliblzfse
      pytz
      mister-skinnylegs
      simplekml
      xlsxwriter
      xmltodict
      tkinter
      zstandard
    ]);
in
  stdenvNoCC.mkDerivation {
    pname = "aleapp";
    version = lib.removePrefix "v" sources.aleapp.version;

    src = sources.aleapp.src;

    nativeBuildInputs = [makeWrapper];

    dontBuild = true;

    # It has no installer and finds its artifact plugins and report assets
    # relative to its own scripts, so the tree is kept whole.
    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/aleapp $out/bin
      cp -r aleapp.py aleappGUI.py assets leapp_functions scripts $out/share/aleapp/
      makeWrapper ${python}/bin/python $out/bin/aleapp --add-flags $out/share/aleapp/aleapp.py
      makeWrapper ${python}/bin/python $out/bin/aleapp-gui --add-flags $out/share/aleapp/aleappGUI.py
      runHook postInstall
    '';

    meta = with lib; {
      description = "Android Logs Events And Protobuf Parser";
      homepage = "https://github.com/abrignoni/ALEAPP";
      license = licenses.mit;
      maintainers = [];
      mainProgram = "aleapp";
      platforms = platforms.linux;
    };
  }
