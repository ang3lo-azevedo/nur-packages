{
  lib,
  stdenvNoCC,
  fetchurl,
  makeDesktopItem,
  copyDesktopItems,
  discord-phoenix,
}:
stdenvNoCC.mkDerivation {
  pname = "sunbird";
  version = "2026.11.25.2333-10f30b3";

  src = fetchurl {
    url = "https://assets.sunbird.tools/plugins/libphoenix-linux-x86_64.so";
    hash = "sha256-YVmKhzsS85nLcuxgBD07PBPQB9GXkMTnbRa/nwhU3L0=";
  };

  dontUnpack = true;
  dontBuild = true;
  preferLocalBuild = true;

  nativeBuildInputs = [
    copyDesktopItems
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "sunbird";
      desktopName = "Sunbird";
      comment = "Discord with Sunbird";
      exec = "sunbird %U";
      icon = "discord";
      startupWMClass = "com.discord.libdiscord";
      categories = [
        "Network"
        "InstantMessaging"
      ];
      mimeTypes = [
        "x-scheme-handler/discord"
      ];
    })
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 "$src" "$out/lib/libphoenix.so"
    mkdir -p "$out/bin"
    cat > "$out/bin/sunbird" <<EOF
    #!/bin/sh
    set -eu
    while [ "\''${1:-}" = --no-runtime ] || [ "\''${1:-}" = --gate-only ]; do
      export SUNBIRD_GATE_ONLY=1
      shift
    done

    # A second Discord hands off to the running one and exits, so restart one
    # running without Sunbird before launching with LD_PRELOAD.
    pids=""
    sunbird_loaded=""
    for p in /proc/[0-9]*; do
      exe=\$(readlink "\$p/exe" 2>/dev/null || true)
      case \$exe in
        */discord-phoenix)
          pids="\$pids \''${p#/proc/}"
          grep -q libphoenix "\$p/maps" 2>/dev/null && sunbird_loaded=1
          ;;
      esac
    done
    if [ -n "\$pids" ] && [ -z "\$sunbird_loaded" ]; then
      kill \$pids 2>/dev/null || true
      for _ in 1 2 3 4 5 6 7 8 9 10; do
        alive=""
        for pid in \$pids; do
          kill -0 "\$pid" 2>/dev/null && alive=1
        done
        [ -z "\$alive" ] && break
        sleep 0.5
      done
    fi

    export LD_PRELOAD="$out/lib/libphoenix.so\''${LD_PRELOAD:+:\$LD_PRELOAD}"
    exec "${lib.getExe discord-phoenix}" "\$@"
    EOF
    chmod 755 "$out/bin/sunbird"

    runHook postInstall
  '';

  meta = {
    description = "Sunbird plugin loader and access gate patcher for Discord Phoenix";
    homepage = "https://sunbird.tools";
    mainProgram = "sunbird";
    platforms = ["x86_64-linux"];
  };
}
