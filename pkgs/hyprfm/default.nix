{ lib
, stdenv
, fetchFromGitHub
, cmake
, pkg-config
, qt6
, glib
, kdePackages
}:

stdenv.mkDerivation rec {
  pname = "hyprfm";
  version = "0.5.3";

  src = fetchFromGitHub {
    owner = "soyeb-jim285";
    repo = "hyprfm";
    rev = "v${version}";
    sha256 = "sha256-1+7q0ntE0Zf9fqUfXB0+v1doO8vAblKSuUHGJDddqkg=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    kdePackages.extra-cmake-modules
    pkg-config
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtdeclarative
    qt6.qtsvg
    glib
    kdePackages.kwindowsystem
  ];

  meta = with lib; {
    description = "A lightweight Qt6/QML file manager for Hyprland";
    homepage = "https://github.com/soyeb-jim285/hyprfm";
    license = licenses.gpl3Only; # Assuming GPL3, standard for such projects. We can check if needed.
    platforms = platforms.linux;
  };
}
