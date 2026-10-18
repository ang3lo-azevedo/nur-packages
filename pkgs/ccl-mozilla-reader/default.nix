{
  lib,
  python3Packages,
  callPackage,
  ccl-simplesnappy,
}: let
  sources = callPackage ../../_sources/generated.nix {};
in
  python3Packages.buildPythonPackage {
    pname = "ccl-mozilla-reader";
    version = "0.0.12-unstable-${sources.ccl-mozilla-reader.date}";
    pyproject = true;

    src = sources.ccl-mozilla-reader.src;

    build-system = with python3Packages; [setuptools];

    dependencies = with python3Packages; [
      brotli
      lz4
      ccl-simplesnappy
    ];

    # upstream pins exact releases of both
    pythonRelaxDeps = ["Brotli" "lz4"];

    pythonImportsCheck = ["ccl_mozilla_reader"];

    meta = with lib; {
      description = "Readers for the storage formats of Firefox based browsers";
      homepage = "https://github.com/cclgroupltd/ccl_mozilla_reader";
      license = licenses.mit;
      maintainers = [];
    };
  }
