{
  lib,
  python3Packages,
}:
python3Packages.buildPythonPackage rec {
  pname = "pansi";
  version = "2024.11.0";
  pyproject = true;

  src = python3Packages.fetchPypi {
    inherit pname version;
    hash = "sha256-AYGGKU8BKuSOIH2URrG9IrDy67LeYKbE+weav6zfSjc=";
  };

  build-system = with python3Packages; [setuptools];

  dependencies = with python3Packages; [pillow];

  pythonImportsCheck = ["pansi"];

  meta = with lib; {
    description = "ANSI escape code library for Python, used by py2neo";
    homepage = "https://github.com/technige/pansi";
    license = licenses.asl20;
    maintainers = [];
  };
}
