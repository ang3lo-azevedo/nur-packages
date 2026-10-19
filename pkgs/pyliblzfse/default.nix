{
  lib,
  python3Packages,
}:
python3Packages.buildPythonPackage rec {
  pname = "pyliblzfse";
  version = "0.4.1";
  pyproject = true;

  src = python3Packages.fetchPypi {
    inherit pname version;
    hash = "sha256-uwuJmzgwwC/fPb3kjqWWEYM/Nm/vg25cMs+BRRNLfT0=";
  };

  build-system = with python3Packages; [setuptools];

  pythonImportsCheck = ["liblzfse"];

  meta = with lib; {
    description = "Python bindings for Apple's LZFSE compression";
    homepage = "https://github.com/ydkhatri/pyliblzfse";
    license = licenses.mit;
    maintainers = [];
  };
}
