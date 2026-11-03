{
  lib,
  python3Packages,
  callPackage,
}: let
  sources = callPackage ../../_sources/generated.nix {};
in
  python3Packages.buildPythonApplication {
    pname = "nup";
    version = sources.nup.version;
    pyproject = true;

    src = sources.nup.src;

    # The reference implementation and its pyproject.toml live under tools/nup.
    sourceRoot = "${sources.nup.src.name}/tools/nup";

    build-system = with python3Packages; [
      setuptools
    ];

    dependencies = with python3Packages; [
      zstandard
    ];

    # No test suite ships with the reference implementation.
    doCheck = false;

    pythonImportsCheck = ["nup"];

    meta = with lib; {
      description = "Reference implementation of the NUP (NX Package) container format for Switch 1/2 game dumps";
      homepage = "https://github.com/a55uka/nup";
      # Upstream ships no license file; treat it as unfree until one is published.
      license = licenses.unfree;
      maintainers = [];
      mainProgram = "nup";
      platforms = platforms.all;
    };
  }
