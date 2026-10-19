{
  lib,
  python3Packages,
  callPackage,
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
    # Only OpenCV 5 loads the DINOv2 model behind visual similarity search;
    # with nixpkgs' OpenCV 4 that one feature fails and the rest works
    pythonRemoveDeps = ["pi-heif"];
    pythonRelaxDeps = ["opencv-python-headless"];

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
