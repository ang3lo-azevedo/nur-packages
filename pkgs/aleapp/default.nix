{
  lib,
  stdenvNoCC,
  python3,
  makeWrapper,
  callPackage,
  mister-skinnylegs,
}: let
  sources = callPackage ../../_sources/generated.nix {};

  bencoding = python3.pkgs.buildPythonPackage rec {
    pname = "bencoding";
    version = "0.2.6";
    pyproject = true;
    src = python3.pkgs.fetchPypi {
      inherit pname version;
      hash = "sha256-Q8zjHUhj4p1rxhFVHU6fJlK+KZXp1eFbRtg4PxgNREA=";
    };
    build-system = [python3.pkgs.setuptools];
    doCheck = false;
  };

  # blackboxprotobuf is left out on purpose: upstream runs its own vendored copy
  python = python3.withPackages (ps:
    with ps; [
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
      pytz
      mister-skinnylegs
      simplekml
      xlsxwriter
      xmltodict
      tkinter
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
