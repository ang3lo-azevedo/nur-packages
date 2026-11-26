{
  lib,
  stdenvNoCC,
  callPackage,
  buildFHSEnv,
  writeShellScriptBin,
}: let
  sources = callPackage ../../_sources/generated.nix {};

  anyps5Data = stdenvNoCC.mkDerivation {
    pname = "anyps5-data";
    inherit (sources.anyps5-relinker) version;
    src = sources.anyps5-prx.src;

    sourceRoot = ".";
    preferLocalBuild = true;
    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall

      install -Dm755 ${sources.anyps5-relinker.src} $out/libexec/anyps5/relinker
      mkdir -p $out/share/anyps5/libs
      cp -a libs/. $out/share/anyps5/libs/

      runHook postInstall
    '';
  };

  anyps5Entry = writeShellScriptBin "anyps5-entry" ''
        export MESA_VK_DEVICE_SELECT="''${MESA_VK_DEVICE_SELECT:-1002:7590}"
        export DRI_PRIME="''${DRI_PRIME:-1}"
        export LD_LIBRARY_PATH="''${LD_LIBRARY_PATH:+''${LD_LIBRARY_PATH}:}${anyps5Data}/share/anyps5/libs"

        if [ "''${ANYPS5_INVOKE_RELINKER:-0}" = "1" ]; then
          unset ANYPS5_INVOKE_RELINKER
          exec "${anyps5Data}/libexec/anyps5/relinker" "$@"
        fi

        case "''${1:-}" in
          ""|-h|--help)
            cat <<'EOF'
    Usage:
      anyps5 <app.elf> [args...]                Run a relinked PS5 ELF inside the FHS environment
      anyps5 run <app.elf> [args...]            Same as above (explicit)
      anyps5 relink [options] <in.elf> <out>    Run AnyPS5 relinker (or invoke `relinker` directly)

    Bundled PRX runtime libraries are automatically available via LD_LIBRARY_PATH
    (${anyps5Data}/share/anyps5/libs), while local ./libs overrides remain supported via $ORIGIN/libs.
    EOF
            exit 0
            ;;
          relink)
            shift
            exec "${anyps5Data}/libexec/anyps5/relinker" "$@"
            ;;
          run)
            shift
            if [ "$#" -eq 0 ]; then
              echo "anyps5: missing executable path after 'run'" >&2
              exit 2
            fi
            exec "$@"
            ;;
          *)
            exec "$@"
            ;;
        esac
  '';

  anyps5Fhs = buildFHSEnv {
    name = "anyps5";
    runScript = "${anyps5Entry}/bin/anyps5-entry";

    targetPkgs = pkgs:
      with pkgs; [
        stdenv.cc.cc.lib
        vulkan-loader
        libglvnd
        libdrm
        libdecor
        wayland
        libx11
        libxcb
        libxext
        libxrandr
        libxkbcommon
        alsa-lib
        libpulseaudio
        pipewire
        dbus
        systemdLibs
        zlib
        gamemode.lib
      ];
  };
in
  stdenvNoCC.mkDerivation {
    pname = "anyps5";
    inherit (sources.anyps5-relinker) version;

    preferLocalBuild = true;
    dontUnpack = true;
    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin $out/share
      ln -s ${anyps5Fhs}/bin/anyps5 $out/bin/anyps5
      ln -s ${anyps5Data}/share/anyps5 $out/share/anyps5

      cat > $out/bin/relinker <<'EOF'
      #!${stdenvNoCC.shell}
      export ANYPS5_INVOKE_RELINKER=1
      exec "${anyps5Fhs}/bin/anyps5" "$@"
      EOF
      chmod +x $out/bin/relinker

      runHook postInstall
    '';

    meta = with lib; {
      description = "PS5 eboot.bin static relinker and native PRX runtime libraries (AnyPS5)";
      homepage = "https://github.com/boykopovar/AnyPS5";
      sourceProvenance = with sourceTypes; [binaryNativeCode];
      license = licenses.gpl2Only;
      platforms = ["x86_64-linux"];
      mainProgram = "anyps5";
    };
  }
