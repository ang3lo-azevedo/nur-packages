{
  lib,
  stdenvNoCC,
  callPackage,
  pkgsCross,
  umu-launcher,
  proton-ge-bin,
}: let
  sources = callPackage ../../_sources/generated.nix {};
  pname = "victory";
  version = "0.1.0-unstable-${sources.victory.date}";

  mingw = pkgsCross.mingw-msvcrt-x86_64;

  victoryExe = mingw.rustPlatform.buildRustPackage {
    pname = "${pname}-exe";
    inherit version;
    inherit (sources.victory) src;

    cargoLock = sources.victory.cargoLock."Cargo.lock";

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
      export WINEPREFIX="\''${WINEPREFIX:-\$data_dir/victory/proton/pfx}"
      export PROTONPATH="\''${PROTONPATH:-${proton-ge-bin.steamcompattool}}"
      export GAMEID="\''${GAMEID:-victory}"
      export MESA_VK_DEVICE_SELECT="\''${MESA_VK_DEVICE_SELECT:-1002:7590}"
      export DRI_PRIME="\''${DRI_PRIME:-1}"
      mkdir -p "\$WINEPREFIX"

      # Initialize the Proton prefix on first run so vkd3d-proton (d3d12/d3d12core)
      # and DXVK (dxgi) are installed into system32 before runinprefix executes.
      if [ ! -e "\$WINEPREFIX/drive_c/windows/system32/d3d12core.dll" ]; then
        "${umu-launcher}/bin/umu-run" cmd.exe /c exit >/dev/null || true
      fi

      export WINEDLLOVERRIDES="d3d12,d3d12core,dxgi=n\''${WINEDLLOVERRIDES:+;\$WINEDLLOVERRIDES}"
      export PROTON_VERB="\''${PROTON_VERB:-runinprefix}"
      exec "${umu-launcher}/bin/umu-run" "$out/opt/victory/victory.exe" "\$@"
      EOF
      chmod 755 "$out/bin/victory"

      runHook postInstall
    '';

    meta = {
      description = "Windows compatibility layer for Xbox Series titles (Belobug AMD fork, Proton-wrapped)";
      homepage = "https://github.com/Belobug/VIctory-Belobug-AMD";
      license = lib.licenses.gpl3Plus;
      mainProgram = "victory";
      platforms = ["x86_64-linux"];
    };
  }
