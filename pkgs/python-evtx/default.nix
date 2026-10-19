{
  lib,
  python3Packages,
}:
python3Packages.buildPythonPackage rec {
  pname = "python-evtx";
  version = "0.8.1";
  pyproject = true;

  src = python3Packages.fetchPypi {
    pname = "python_evtx";
    inherit version;
    hash = "sha256-6WzqJVNqPeUHSvfxvb8BEITQnC4AZkq3VNl5gg7XX+o=";
  };

  build-system = with python3Packages; [setuptools];

  dependencies = with python3Packages; [hexdump];

  pythonImportsCheck = ["Evtx"];

  meta = with lib; {
    description = "Pure Python parser for Windows event log (EVTX) files";
    homepage = "https://github.com/williballenthin/python-evtx";
    license = licenses.asl20;
    maintainers = [];
  };
}
