{
  lib,
  python3,
  callPackage,
  ctfbridge,
}: let
  sources = callPackage ../_sources/generated.nix {};
in
  python3.pkgs.buildPythonApplication {
    pname = "ctf-dl";
    version = "0.0.0";
    pyproject = true;

    src = sources."ctf-dl".src;

    build-system = with python3.pkgs; [
      setuptools
      setuptools-scm
      wheel
    ];

    dependencies = with python3.pkgs; [
      ctfbridge
      httpx
      typer
      rich
      jinja2
      pyyaml
      python-slugify
      mdformat
      mdformat-gfm
    ];

    postPatch = ''
      sed -i -e 's/mdformat==0.7.22/mdformat/g' -e 's/mdformat_tables==1.0.0/mdformat-gfm/g' pyproject.toml
    '';

    doCheck = false;

    SETUPTOOLS_SCM_PRETEND_VERSION = "0.0.0";

    meta = with lib; {
      description = "Command-line tool to download CTF challenges";
      homepage = "https://github.com/bjornmorten/ctf-dl";
      license = licenses.mit;
      maintainers = [];
    };
  }
