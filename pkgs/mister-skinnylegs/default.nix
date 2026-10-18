{
  lib,
  python3Packages,
  callPackage,
  ccl-chromium-reader,
  ccl-mozilla-reader,
}: let
  sources = callPackage ../../_sources/generated.nix {};
in
  python3Packages.buildPythonPackage {
    pname = "mister-skinnylegs";
    version = lib.removePrefix "v" sources.mister-skinnylegs.version;
    pyproject = true;

    src = sources.mister-skinnylegs.src;

    build-system = with python3Packages; [setuptools];

    dependencies = [
      ccl-chromium-reader
      ccl-mozilla-reader
    ];

    pythonImportsCheck = ["mister_skinnylegs"];

    meta = with lib; {
      description = "Plugin framework for parsing website artifacts in browser data";
      homepage = "https://github.com/cclgroupltd/mister-skinnylegs";
      license = licenses.mit;
      maintainers = [];
      mainProgram = "mister-skinnylegs";
    };
  }
