{
  lib,
  python3Packages,
}:
python3Packages.buildPythonPackage rec {
  pname = "bencoding";
  version = "0.2.6";
  pyproject = true;

  src = python3Packages.fetchPypi {
    inherit pname version;
    hash = "sha256-Q8zjHUhj4p1rxhFVHU6fJlK+KZXp1eFbRtg4PxgNREA=";
  };

  build-system = with python3Packages; [setuptools];

  doCheck = false;

  pythonImportsCheck = ["bencoding"];

  meta = with lib; {
    description = "Bencode encoder and decoder";
    homepage = "https://github.com/dust8/bencoding";
    license = licenses.mit;
    maintainers = [];
  };
}
