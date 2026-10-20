{
  lib,
  python3Packages,
  callPackage,
  copyDesktopItems,
  makeDesktopItem,
  gobject-introspection,
  gtk3,
  webkitgtk_4_1,
  wrapGAppsHook3,
  pyliblzfse,
  texture2ddecoder,
}: let
  sources = callPackage ../../_sources/generated.nix {};
in
  python3Packages.buildPythonApplication {
    pname = "gleapp";
    version = lib.removePrefix "v" sources.gleapp.version;
    pyproject = true;

    src = sources.gleapp.src;

    build-system = with python3Packages; [setuptools];

    nativeBuildInputs = [
      copyDesktopItems
      gobject-introspection
      wrapGAppsHook3
    ];

    # The desktop window is pywebview on its GTK backend
    buildInputs = [
      gtk3
      webkitgtk_4_1
    ];

    dependencies = with python3Packages; [
      flask
      imagehash
      numpy
      opencv-python-headless
      pillow
      pillow-heif
      py7zr
      pycryptodome
      pycryptodomex
      pygobject3
      pyliblzfse
      pypdf
      pywebview
      texture2ddecoder
      tzdata
      zstandard
    ];

    # pi-heif is the slim build of pillow-heif, which GLEAPP falls back to.
    pythonRemoveDeps = ["pi-heif"];
    # FIXME: Drop once nixpkgs has OpenCV 5. Only OpenCV 5 loads the DINOv2 model
    # behind visual similarity search; with OpenCV 4 that one feature fails
    pythonRelaxDeps = ["opencv-python-headless"];

    desktopItems = [
      (makeDesktopItem {
        name = "gleapp";
        desktopName = "GLEAPP";
        comment = "Triage images and video from extractions and disk images";
        exec = "gleapp-desktop";
        icon = "gleapp";
        categories = ["System" "Utility"];
      })
    ];

    postInstall = ''
      install -Dm444 gleapp/web/static/gleapp-logo.png $out/share/icons/hicolor/256x256/apps/gleapp.png
    '';

    dontWrapGApps = true;
    preFixup = ''
      makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
    '';

    pythonImportsCheck = ["gleapp"];

    meta = with lib; {
      description = "Image and video forensic triage toolkit from the LEAPP family";
      homepage = "https://github.com/abrignoni/GLEAPP";
      license = with licenses; [mit asl20 bsd3 ofl cc0];
      maintainers = [];
      mainProgram = "gleapp";
      platforms = platforms.linux;
    };
  }
