{
  lib,
  python3,
  callPackage,
}: let
  sources = callPackage ../../_sources/generated.nix {};
in
  python3.pkgs.buildPythonPackage {
    pname = "ctfbridge";
    version = "0.9.0";
    pyproject = true;

    src = sources.ctfbridge.src;

    build-system = with python3.pkgs; [
      setuptools
      setuptools-scm
      wheel
    ];

    dependencies = with python3.pkgs; [
      beautifulsoup4
      pydantic
      httpx
      asyncssh
      markdownify
    ];

    doCheck = false;

    SETUPTOOLS_SCM_PRETEND_VERSION = "0.9.0";

    meta = with lib; {
      description = "A Python library for interacting with multiple CTF platforms";
      homepage = "https://github.com/bjornmorten/ctfbridge";
      license = licenses.mit;
      maintainers = [];
    };
  }
