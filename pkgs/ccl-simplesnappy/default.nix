{
  lib,
  python3Packages,
  callPackage,
}: let
  sources = callPackage ../../_sources/generated.nix {};
in
  python3Packages.buildPythonPackage {
    pname = "ccl-simplesnappy";
    version = "0.4-unstable-${sources.ccl-simplesnappy.date}";
    pyproject = true;

    src = sources.ccl-simplesnappy.src;

    build-system = with python3Packages; [setuptools];

    pythonImportsCheck = ["ccl_simplesnappy"];

    meta = with lib; {
      description = "Pure Python Snappy decompressor";
      homepage = "https://github.com/cclgroupltd/ccl_simplesnappy";
      license = licenses.mit;
      maintainers = [];
    };
  }
