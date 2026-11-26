{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  pkgsCross,
  wineWow64Packages,
}: let
  pname = "victory";
  version = "0.1.0-unstable-2026-11-26";
  rev = "cd8dfc06ace7ccb91a19431e74bc2d0de2a10145";

  src = fetchFromGitHub {
    owner = "Belobug";
    repo = "VIctory-Belobug-AMD";
    inherit rev;
    hash = "sha256-fdoSziay1qKvD/iGcbSGx09zBZd72nmhQiKCWhkgQCo=";
  };

  mingw = pkgsCross.mingw-msvcrt-x86_64;

  victoryExe = mingw.rustPlatform.buildRustPackage {
    pname = "${pname}-exe";
    inherit version src;

    cargoLock = {
      lockFile = "${src}/Cargo.lock";
    };

    cargoBuildFlags = [
      "-p"
      "victory"
    ];

    buildInputs = [
      mingw.windows.pthreads
    ];

    RUSTFLAGS = "-L ${mingw.windows.pthreads}/lib";

    # Tests exercise Windows-host D3D12/xmem APIs directly.
    doCheck = false;
  };
in
  stdenvNoCC.mkDerivation {
    inherit pname version;

    dontUnpack = true;
    dontBuild = true;
    preferLocalBuild = true;

    installPhase = ''
      runHook preInstall

      mkdir -p "$out/opt/victory" "$out/bin"
      cp "${victoryExe}/bin/victory.exe" "$out/opt/victory/victory.exe"
      ln -s "$out/opt/victory/victory.exe" "$out/bin/victory.exe"

      cat > "$out/bin/victory" <<EOF
      #!/bin/sh
      set -eu
      data_dir="\''${XDG_DATA_HOME:-\$HOME/.local/share}"
      export WINEPREFIX="\''${WINEPREFIX:-\$data_dir/victory/wine}"
      export WINEARCH=win64
      export MESA_VK_DEVICE_SELECT="\''${MESA_VK_DEVICE_SELECT:-1002:7590}"
      export DRI_PRIME="\''${DRI_PRIME:-1}"
      mkdir -p "\$WINEPREFIX"
      exec "${wineWow64Packages.waylandFull}/bin/wine" "$out/opt/victory/victory.exe" "\$@"
      EOF
      chmod 755 "$out/bin/victory"

      runHook postInstall
    '';

    meta = {
      description = "Windows compatibility layer for Xbox Series titles (Belobug AMD fork, Wine-wrapped)";
      homepage = "https://github.com/Belobug/VIctory-Belobug-AMD";
      license = lib.licenses.gpl3Plus;
      mainProgram = "victory";
      platforms = ["x86_64-linux"];
    };
  }
