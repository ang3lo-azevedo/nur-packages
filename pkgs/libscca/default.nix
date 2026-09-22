{
  stdenv,
  fetchurl,
  pkg-config,
}:
stdenv.mkDerivation rec {
  pname = "libscca";
  version = "20260527";

  # libyal ships this one under the "alpha" name rather than the "experimental"
  # name used by libesedb and libfsntfs.
  src = fetchurl {
    url = "https://github.com/libyal/libscca/releases/download/${version}/libscca-alpha-${version}.tar.gz";
    sha256 = "sha256-X6ijq2ArRDHnXmH00h69RhdMUkp5Fz+MDq3KJM3b3BY=";
  };

  nativeBuildInputs = [pkg-config];
}
