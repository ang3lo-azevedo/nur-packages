{
  lib,
  python3Packages,
  callPackage,
  ccl-simplesnappy,
}: let
  sources = callPackage ../../_sources/generated.nix {};
in
  python3Packages.buildPythonPackage {
    pname = "ccl-chromium-reader";
    version = "0.3.18-unstable-${sources.ccl-chromium-reader.date}";
    pyproject = true;

    src = sources.ccl-chromium-reader.src;

    build-system = with python3Packages; [setuptools];

    dependencies = with python3Packages; [
      brotli
      zstd
      ccl-simplesnappy
    ];

    # upstream pins exact releases of both
    pythonRelaxDeps = ["Brotli" "zstd"];

    pythonImportsCheck = ["ccl_chromium_reader"];

    meta = with lib; {
      description = "Readers for the storage formats of Chromium based browsers";
      homepage = "https://github.com/cclgroupltd/ccl_chromium_reader";
      license = licenses.mit;
      maintainers = [];
    };
  }
