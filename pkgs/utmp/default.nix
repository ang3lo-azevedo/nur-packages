{
  lib,
  python3Packages,
}:
python3Packages.buildPythonPackage rec {
  pname = "utmp";
  version = "21.10.0";
  pyproject = true;

  src = python3Packages.fetchPypi {
    inherit pname version;
    hash = "sha256-IBp1jnkLborSwhI4ijjyCnHVCOcXtxTVjxlJyPzE3l0=";
  };

  # Lint and compatibility tools listed as setup requirements, unused when building
  postPatch = ''
    substituteInPlace setup.py --replace-fail "setup_requires=['six', 'flake8']," ""
  '';

  build-system = with python3Packages; [setuptools];

  pythonImportsCheck = ["utmp"];

  meta = with lib; {
    description = "Decoder for Linux utmp, wtmp and btmp login records";
    homepage = "https://github.com/hjacobs/utmp";
    license = licenses.asl20;
    maintainers = [];
  };
}
