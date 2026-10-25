{
  lib,
  python3Packages,
  fetchFromGitHub,
  interchange,
  pansi,
}:
python3Packages.buildPythonPackage {
  pname = "py2neo";
  # Upstream py2neo is archived; elena's fork keeps it working on current neo4j.
  # Its VERSION file reads 2021.2.dev0
  version = "2021.2-unstable-2023-05-19";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "elena";
    repo = "py2neo";
    rev = "7f57cbe1797945ce27e93cfd6ee5dfa291129be5";
    hash = "sha256-YzLgYQscn8i8sN9HMjTNf8BtcduAe6kD2xLQc8r16cU=";
  };

  build-system = with python3Packages; [setuptools];

  dependencies =
    [interchange pansi]
    ++ (with python3Packages; [certifi monotonic packaging pygments six urllib3]);

  pythonImportsCheck = ["py2neo"];

  meta = with lib; {
    description = "Client library and toolkit for working with Neo4j (maintained fork)";
    homepage = "https://github.com/elena/py2neo";
    license = licenses.asl20;
    maintainers = [];
  };
}
