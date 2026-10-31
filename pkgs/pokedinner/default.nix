{
  appimageTools,
  fetchurl,
  makeWrapper,
  symlinkJoin,
}: let
  pname = "pokedinner";

  # PokeDinner is a fork of Eglantine (itself derived from Eden/Yuzu/Sudachi),
  # kept alongside eglantine so the two can be compared. Unlike eglantine the
  # releases use plain semver tags and a commit-free asset name, so the URL
  # templates cleanly: bump `version` and `hash` from the newest release at
  # https://git.eden-emu.dev/Franseven/PokeDinner-a-Eglantine-Fork/releases.
  version = "2.0.0";

  src = fetchurl {
    url = "https://git.eden-emu.dev/Franseven/PokeDinner-a-Eglantine-Fork/releases/download/${version}/Eglantine-PokeDinner-${version}-linux-x86_64.AppImage";
    hash = "sha256-9bl/Ze1wOW0YbRe1JgnwOskHIIJQ8VvSjl12GyPWPpo=";
  };

  # The desktop entry and icon sit at the AppImage root (not under usr/share as
  # eglantine's do), both named eglantine.* and still pointing Exec/Icon at the
  # eglantine binary; we rewrite those below so it coexists with eglantine.
  contents = appimageTools.extract {inherit pname version src;};

  # wrapType2 runs the AppImage in an FHS sandbox; its binary is $out/bin/pokedinner.
  # vulkan-loader lets the bundled app reach the NixOS GPU drivers under
  # /run/opengl-driver so Vulkan (the emulator's main renderer) works. libgpg-error
  # is linked by a bundled lib but absent from appimageTools' default FHS on this
  # nixpkgs, so the AppImage fails to load without it.
  fhs = appimageTools.wrapType2 {
    inherit pname version src;
    extraPkgs = pkgs: [pkgs.vulkan-loader pkgs.libgpg-error];
  };
in
  symlinkJoin {
    name = "${pname}-${version}";
    paths = [fhs];
    nativeBuildInputs = [makeWrapper];

    postBuild = ''
      # Offload to the AMD eGPU (Navi 44, RX 9060 XT, 1002:7590) for Vulkan, with
      # DRI_PRIME for any GL path. --set-default so an unplugged eGPU falls back to
      # the iGPU and a manual env still wins.
      #
      # The AppImage bundles only the xcb Qt platform plugin (no qtwayland), so under
      # a Wayland session that exports QT_QPA_PLATFORM=wayland it finds no usable
      # plugin and aborts. Force xcb so it runs through XWayland (xwayland-satellite).
      wrapProgram $out/bin/${pname} \
        --set QT_QPA_PLATFORM xcb \
        --set-default MESA_VK_DEVICE_SELECT 1002:7590 \
        --set-default DRI_PRIME 1

      # The bundled entry calls itself "Eglantine" and runs the eglantine binary;
      # retarget it at this package so it shows up as its own launcher item next to
      # eglantine instead of colliding with it.
      install -Dm444 ${contents}/eglantine.desktop \
        $out/share/applications/${pname}.desktop
      substituteInPlace $out/share/applications/${pname}.desktop \
        --replace-warn "Name=Eglantine" "Name=PokeDinner (Eglantine fork)" \
        --replace-warn "Exec=eglantine" "Exec=${pname}" \
        --replace-warn "Icon=eglantine" "Icon=${pname}" \
        --replace-warn "StartupWMClass=eglantine" "StartupWMClass=${pname}"

      install -Dm444 ${contents}/eglantine.png \
        $out/share/icons/hicolor/512x512/apps/${pname}.png
    '';

    meta = {
      description = "PokeDinner: a fork of the Eglantine Switch emulator (upstream AppImage)";
      homepage = "https://git.eden-emu.dev/Franseven/PokeDinner-a-Eglantine-Fork";
      mainProgram = pname;
      platforms = ["x86_64-linux"];
    };
  }
