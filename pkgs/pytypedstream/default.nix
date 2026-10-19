{
  lib,
  python3Packages,
}:
python3Packages.buildPythonPackage rec {
  pname = "pytypedstream";
  version = "0.1.0";
  pyproject = true;

  src = python3Packages.fetchPypi {
    inherit pname version;
    hash = "sha256-w7AXkOZnGJlm6Y/P62OMwFQTWOpzSHRWGf5Y4+jJ/VE=";
  };

  build-system = with python3Packages; [setuptools];

  pythonImportsCheck = ["typedstream"];

  meta = with lib; {
    description = "Reader for Apple's NeXTSTEP typedstream format";
    homepage = "https://github.com/dgelessus/python-typedstream";
    license = licenses.lgpl3Plus;
    maintainers = [];
  };
}
