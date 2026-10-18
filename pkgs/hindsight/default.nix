{
  lib,
  python3Packages,
  callPackage,
  ccl-chromium-reader,
}: let
  sources = callPackage ../../_sources/generated.nix {};
in
  python3Packages.buildPythonApplication {
    pname = "hindsight";
    version = lib.removePrefix "v" sources.hindsight.version;
    pyproject = true;

    src = sources.hindsight.src;

    build-system = with python3Packages; [setuptools];

    dependencies = with python3Packages; [
      bottle
      keyring
      protobuf
      puremagic
      pycryptodomex
      rich
      tzdata
      xlsxwriter
      # Not in upstream's metadata because it is not on PyPI. Without it the
      # cache, IndexedDB and LocalStorage parsers are silently skipped.
      ccl-chromium-reader
    ];

    pythonRelaxDeps = ["puremagic"];

    pythonImportsCheck = ["pyhindsight"];

    meta = with lib; {
      description = "Browser forensics for Google Chrome and Chromium";
      homepage = "https://github.com/obsidianforensics/hindsight";
      license = licenses.asl20;
      maintainers = [];
      mainProgram = "hindsight";
    };
  }
