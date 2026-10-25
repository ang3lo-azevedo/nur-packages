{
  lib,
  python3Packages,
}:
python3Packages.buildPythonPackage rec {
  pname = "interchange";
  version = "2021.0.4";
  pyproject = true;

  src = python3Packages.fetchPypi {
    inherit pname version;
    hash = "sha256-Z5HRs0Yh6ZADX+ddgIUjFyNA2AreG1BBIiaCAYQZlVA=";
  };

  build-system = with python3Packages; [setuptools];

  dependencies = with python3Packages; [pytz six];

  pythonImportsCheck = ["interchange"];

  meta = with lib; {
    description = "Data types and interchange formats, used by py2neo";
    homepage = "https://github.com/technige/interchange";
    license = licenses.asl20;
    maintainers = [];
  };
}
