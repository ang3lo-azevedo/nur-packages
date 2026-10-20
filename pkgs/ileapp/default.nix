{
  lib,
  stdenvNoCC,
  python3,
  makeWrapper,
  copyDesktopItems,
  makeDesktopItem,
  callPackage,
  astc-decomp-faster,
  bencoding,
  mdplistlib,
  nska-deserialize,
  pyliblzfse,
  pytypedstream,
  unifiedlog-iterator,
}: let
  sources = callPackage ../../_sources/generated.nix {};
  writable-copies = callPackage ../leapp-common {};

  # blackboxprotobuf is left out on purpose: upstream runs its own vendored copy
  python = python3.withPackages (ps:
    with ps; [
      writable-copies
      astc-decomp-faster
      bencoding
      beautifulsoup4
      biplist
      cryptography
      ijson
      mdplistlib
      mmh3
      nska-deserialize
      numpy
      packaging
      pandas
      pgpy
      pillow
      pillow-heif
      protobuf
      pyasn1
      pycryptodome
      pyliblzfse
      pytypedstream
      pytz
      simplekml
      standard-imghdr
      tkinter
      zstandard
    ]);
in
  stdenvNoCC.mkDerivation {
    pname = "ileapp";
    version = lib.removePrefix "v" sources.ileapp.version;

    src = sources.ileapp.src;

    nativeBuildInputs = [
      makeWrapper
      copyDesktopItems
    ];

    dontBuild = true;

    # The GUI looks for its assets under the working directory, which only
    # works when it is started from a source checkout
    postPatch = ''
      substituteInPlace ileappGUI.py \
        --replace-fail 'base_path = os.path.abspath(".")' 'base_path = os.path.dirname(os.path.abspath(__file__))'
    '';

    desktopItems = [
      (makeDesktopItem {
        name = "ileapp";
        desktopName = "iLEAPP";
        comment = "Parse iOS extractions into a forensic report";
        exec = "ileapp-gui";
        icon = "ileapp";
        categories = ["System" "Utility"];
      })
    ];

    # It has no installer and finds its artifact plugins and report assets
    # relative to its own scripts, so the tree is kept whole.
    # Unified Log parsing looks for unifiedlog_iterator on PATH, which upstream
    # otherwise downloads as a prebuilt binary
    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/ileapp $out/bin
      install -Dm444 assets/icon.png $out/share/icons/hicolor/256x256/apps/ileapp.png
      cp -r ileapp.py ileappGUI.py assets leapp_functions scripts $out/share/ileapp/
      makeWrapper ${python}/bin/python $out/bin/ileapp --add-flags $out/share/ileapp/ileapp.py \
        --prefix PATH : ${lib.makeBinPath [unifiedlog-iterator]}
      makeWrapper ${python}/bin/python $out/bin/ileapp-gui --add-flags $out/share/ileapp/ileappGUI.py \
        --prefix PATH : ${lib.makeBinPath [unifiedlog-iterator]}
      runHook postInstall
    '';

    meta = with lib; {
      description = "iOS Logs, Events, And Plists Parser";
      homepage = "https://github.com/abrignoni/iLEAPP";
      license = licenses.mit;
      maintainers = [];
      mainProgram = "ileapp";
      platforms = platforms.linux;
    };
  }
