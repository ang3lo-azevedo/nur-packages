{
  lib,
  stdenvNoCC,
  python3,
  makeWrapper,
  copyDesktopItems,
  makeDesktopItem,
  callPackage,
  bencoding,
  pyliblzfse,
  python-evtx,
  unifiedlog-iterator,
}: let
  sources = callPackage ../../_sources/generated.nix {};
  writable-copies = callPackage ../leapp-common {};

  python = python3.withPackages (ps:
    with ps; [
      writable-copies
      argon2-cffi
      beautifulsoup4
      bencoding
      brotli
      ijson
      mammoth
      olefile
      openpyxl
      packaging
      pdfminer-six
      pefile
      pillow
      pillow-heif
      pycryptodome
      pyliblzfse
      pynacl
      pypdf
      python-evtx
      # The 1.4 tag still says 1.3.1 in its metadata, which fails the build
      (python-registry.overridePythonAttrs {dontCheckPythonMetadata = true;})
      pytz
      requests
      simplekml
      tkinter
      xmltodict
      zstandard
    ]);
in
  stdenvNoCC.mkDerivation {
    pname = "dleapp";
    version = lib.removePrefix "v" sources.dleapp.version;

    src = sources.dleapp.src;

    nativeBuildInputs = [
      makeWrapper
      copyDesktopItems
    ];

    dontBuild = true;

    # The GUI looks for its assets under the working directory, which only
    # works when it is started from a source checkout
    postPatch = ''
      substituteInPlace dleappGUI.py \
        --replace-fail 'base_path = os.path.abspath(".")' 'base_path = os.path.dirname(os.path.abspath(__file__))'
    '';

    desktopItems = [
      (makeDesktopItem {
        name = "dleapp";
        desktopName = "DLEAPP";
        comment = "Parse desktop app and Windows artifacts into a forensic report";
        exec = "dleapp-gui";
        icon = "dleapp";
        categories = ["System" "Utility"];
      })
    ];

    # It has no installer and finds its artifact plugins and report assets
    # relative to its own scripts, so the tree is kept whole.
    # Unified Log parsing looks for unifiedlog_iterator on PATH, which upstream
    # otherwise downloads as a prebuilt binary
    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/dleapp $out/bin
      install -Dm444 assets/icon.png $out/share/icons/hicolor/256x256/apps/dleapp.png
      cp -r dleapp.py dleappGUI.py assets leapp_functions scripts *.dlprofile $out/share/dleapp/
      makeWrapper ${python}/bin/python $out/bin/dleapp --add-flags $out/share/dleapp/dleapp.py \
        --prefix PATH : ${lib.makeBinPath [unifiedlog-iterator]}
      makeWrapper ${python}/bin/python $out/bin/dleapp-gui --add-flags $out/share/dleapp/dleappGUI.py \
        --prefix PATH : ${lib.makeBinPath [unifiedlog-iterator]}
      runHook postInstall
    '';

    meta = with lib; {
      description = "Desktop Logs, Events, And Protobuf Parser for desktop and Electron app artifacts";
      homepage = "https://github.com/abrignoni/DLEAPP";
      license = licenses.mit;
      maintainers = [];
      mainProgram = "dleapp";
      platforms = platforms.linux;
    };
  }
