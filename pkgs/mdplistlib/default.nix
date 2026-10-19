{
  lib,
  python3Packages,
}:
python3Packages.buildPythonPackage rec {
  pname = "mdplistlib";
  version = "0.1.3";
  pyproject = true;

  src = python3Packages.fetchPypi {
    inherit pname version;
    hash = "sha256-86OtiJnmXvUrfInUqa4jNAvv5Vr9wUylqi4JIFq5HDE=";
  };

  build-system = with python3Packages; [setuptools];

  pythonImportsCheck = ["mdplist"];

  meta = with lib; {
    description = "Parser for Apple Spotlight metadata plists";
    homepage = "https://github.com/snoop168/mdplistlib";
    license = licenses.mit;
    maintainers = [];
  };
}
