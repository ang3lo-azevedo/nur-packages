{
  lib,
  python3Packages,
}:
python3Packages.buildPythonPackage rec {
  pname = "freesimplegui";
  version = "5.3.0.post1";
  pyproject = true;

  src = python3Packages.fetchPypi {
    inherit pname version;
    hash = "sha256-z8VxLGgDvfbwOqqhiwg6VKGj9CVCIa8Guwj6pKaqlxk=";
  };

  build-system = with python3Packages; [setuptools];

  dependencies = with python3Packages; [tkinter];

  pythonImportsCheck = ["FreeSimpleGUI"];

  meta = with lib; {
    description = "LGPL fork of PySimpleGUI 4, kept compatible with its API";
    homepage = "https://github.com/spyoungtech/FreeSimpleGUI";
    license = licenses.lgpl3Plus;
    maintainers = [];
  };
}
