{
  lib,
  python3Packages,
  pydicti,
}:
python3Packages.buildPythonPackage rec {
  pname = "apachelogs";
  version = "0.6.1";
  pyproject = true;

  src = python3Packages.fetchPypi {
    inherit pname version;
    hash = "sha256-R3DZWemCrxJ0aeM7HGvuGBELJ9hNphhF7wRz7whzt6o=";
  };

  build-system = with python3Packages; [hatchling];

  dependencies = [
    python3Packages.attrs
    pydicti
  ];

  pythonImportsCheck = ["apachelogs"];

  meta = with lib; {
    description = "Parser for Apache access log files";
    homepage = "https://github.com/jwodder/apachelogs";
    license = licenses.mit;
    maintainers = [];
  };
}
