{
  appimageTools,
  fetchurl,
  makeWrapper,
  symlinkJoin,
}: let
  pname = "horizon-launcher";

  # Horizon: Minecraft Java Edition rewritten in Rust (horizon-rust/horizon). The
  # launcher installs, prepares and runs the game. Upstream ships it as a prebuilt
  # AppImage; the stable launcher releases are tagged launcher@X.Y.Z and the asset
  # name is constant, so the URL templates off the tag. Run ./update.sh to refresh
  # `version` and `hash` to the newest launcher release.
  version = "launcher@0.2.49";

  src = fetchurl {
    url = "https://github.com/horizon-rust/horizon/releases/download/${version}/horizon-launcher-linux-x86_64.AppImage";
    hash = "sha256-wePEii/SrykbSls99LY6BzpiHTUrJ4IFdcLK0ndk25E=";
  };

  # The desktop entry (Exec=horizon-launcher already) and icon live inside the AppImage.
  contents = appimageTools.extract {inherit pname version src;};

  # wrapType2 runs the AppImage in an FHS sandbox; its binary is $out/bin/horizon-launcher.
  # The launcher itself is a light native GUI (xcb/xkbcommon, in the default FHS), but it
  # downloads and spawns the game, which renders through wgpu: vulkan-loader reaches the
  # NixOS drivers under /run/opengl-driver for Vulkan, libGL covers the GL path, and
  # wayland/alsa-lib/libpulse cover its windowing and audio, none of which the launcher
  # links directly so they are absent from the default FHS.
  fhs = appimageTools.wrapType2 {
    inherit pname version src;
    extraPkgs = pkgs: [
      pkgs.vulkan-loader
      pkgs.libGL
      pkgs.wayland
      pkgs.libxkbcommon
      pkgs.alsa-lib
      pkgs.libpulseaudio
    ];
  };
in
  symlinkJoin {
    name = "${pname}-${version}";
    paths = [fhs];
    nativeBuildInputs = [makeWrapper];

    postBuild = ''
      # Offload the game to the AMD eGPU (Navi 44, RX 9060 XT, 1002:7590) for Vulkan,
      # with DRI_PRIME for any GL path. --set-default so an unplugged eGPU falls back to
      # the iGPU and a manual env still wins.
      wrapProgram $out/bin/${pname} \
        --set-default MESA_VK_DEVICE_SELECT 1002:7590 \
        --set-default DRI_PRIME 1

      install -Dm444 ${contents}/horizon-launcher.desktop \
        $out/share/applications/horizon-launcher.desktop
      install -Dm444 ${contents}/usr/share/icons/hicolor/512x512/apps/horizon.png \
        $out/share/icons/hicolor/512x512/apps/horizon.png
    '';

    meta = {
      description = "Horizon launcher: Minecraft Java Edition rewritten from scratch in Rust (upstream AppImage)";
      homepage = "https://github.com/horizon-rust/horizon";
      mainProgram = pname;
      platforms = ["x86_64-linux"];
    };
  }
