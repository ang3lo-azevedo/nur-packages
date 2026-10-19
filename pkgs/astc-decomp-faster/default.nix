{
  lib,
  python3Packages,
}:
python3Packages.buildPythonPackage rec {
  pname = "astc-decomp-faster";
  version = "1.1.5";
  pyproject = true;

  src = python3Packages.fetchPypi {
    pname = "astc_decomp_faster";
    inherit version;
    hash = "sha256-yEhlyXIxmWqaTxLJ9NZ2YzgIr+YvTfIw39dA7n0wVLQ=";
  };

  # The sdist ships only the .pyx, so Cython must be there to compile it
  build-system = with python3Packages; [cython setuptools];

  dependencies = with python3Packages; [pillow];

  pythonImportsCheck = ["astc_decomp_faster"];

  meta = with lib; {
    description = "Pillow decoder for ASTC compressed textures";
    homepage = "https://github.com/bconstanzo/astc_decomp_faster";
    license = licenses.mit;
    maintainers = [];
  };
}
