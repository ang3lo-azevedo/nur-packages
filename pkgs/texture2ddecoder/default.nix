{
  lib,
  python3Packages,
}:
python3Packages.buildPythonPackage rec {
  pname = "texture2ddecoder";
  version = "1.0.6";
  pyproject = true;

  src = python3Packages.fetchPypi {
    inherit pname version;
    hash = "sha256-iPBNiVEBisE7jazQflfora1Kbxz+VQlkbooQIDRqgco=";
  };

  # The cap only works around PyPy 3.8
  postPatch = ''
    substituteInPlace pyproject.toml --replace-fail '"setuptools<72.2.0"' '"setuptools"'
  '';

  build-system = with python3Packages; [setuptools];

  pythonImportsCheck = ["texture2ddecoder"];

  meta = with lib; {
    description = "Decoder for GPU texture formats (ASTC, BCn, ETC, PVRTC)";
    homepage = "https://github.com/K0lb3/texture2ddecoder";
    license = licenses.mit;
    maintainers = [];
  };
}
