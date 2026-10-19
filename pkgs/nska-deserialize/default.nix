{
  lib,
  python3Packages,
}:
python3Packages.buildPythonPackage rec {
  pname = "nska-deserialize";
  version = "1.5.1";
  pyproject = true;

  src = python3Packages.fetchPypi {
    pname = "nska_deserialize";
    inherit version;
    hash = "sha256-qAQP3OGcVGc8CL/bqaO8nrHsUZsGuVdfInRAunjsCAk=";
  };

  build-system = with python3Packages; [setuptools];

  dependencies = with python3Packages; [biplist];

  pythonImportsCheck = ["nska_deserialize"];

  meta = with lib; {
    description = "Deserializer for Apple NSKeyedArchiver plists";
    homepage = "https://github.com/ydkhatri/nska_deserialize";
    license = licenses.mit;
    maintainers = [];
  };
}
