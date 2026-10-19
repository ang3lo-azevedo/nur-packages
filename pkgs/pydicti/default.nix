{
  lib,
  python3Packages,
}:
python3Packages.buildPythonPackage rec {
  pname = "pydicti";
  version = "1.2.1";
  pyproject = true;

  src = python3Packages.fetchPypi {
    inherit pname version;
    hash = "sha256-Y+B1b/J6M16SkW/0C+WJohpYiUs6kwme3w88v2lWkNw=";
  };

  build-system = with python3Packages; [setuptools];

  pythonImportsCheck = ["pydicti"];

  meta = with lib; {
    description = "Case-insensitive dictionaries for Python";
    homepage = "https://github.com/coldfix/pydicti";
    license = licenses.wtfpl;
    maintainers = [];
  };
}
