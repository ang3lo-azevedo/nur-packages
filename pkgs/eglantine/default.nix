{
  appimageTools,
  fetchurl,
  makeWrapper,
  symlinkJoin,
}: let
  pname = "eglantine";

  # Upstream's prebuilt nx2 AppImage (PGO build). All upstream builds are
  # prereleases nvfetcher skips, so run ./update.sh to refresh `version` and
  # `hash` to the newest release by publish date that ships the PGO AppImage.
  # `version` is the release tag: upstream publishes several kinds (build-NN,
  # daily-*, v*, and throwaway branch-<name>-<hash> testing builds) and the
  # newest PGO one by date may be any of them. Requiring the PGO asset skips the
  # testing builds, which do not ship one; the stable builds all ship
  # eglantine-linux-x86_64-pgo.AppImage, so the URL below templates off the tag.
  version = "branch-exp-nx2-welcome-tour-1121-86e84297";

  src = fetchurl {
    url = "https://github.com/Djihads80/Eglantine/releases/download/${version}/eglantine-linux-x86_64-pgo.AppImage";
    hash = "sha256-zMbjo5LdlaASLRPUkGkRx/WWia76Dse4lfDjA6rckMQ=";
  };

  # The desktop entry (Exec=eglantine already) and icon live inside the AppImage.
  contents = appimageTools.extract {inherit pname version src;};

  # wrapType2 runs the AppImage in an FHS sandbox; its binary is $out/bin/eglantine.
  # vulkan-loader lets the bundled app reach the NixOS GPU drivers under
  # /run/opengl-driver so Vulkan (the emulator's main renderer) works. libgpg-error
  # is linked by a bundled lib but, unlike libgcrypt, is absent from appimageTools'
  # default FHS on this nixpkgs, so the AppImage fails to load without it.
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

      install -Dm444 ${contents}/usr/share/applications/dev.eden_emu.eden.desktop \
        $out/share/applications/eglantine.desktop
      install -Dm444 ${contents}/usr/share/icons/hicolor/512x512/apps/dev.eglantine.eglantine.png \
        $out/share/icons/hicolor/512x512/apps/dev.eglantine.eglantine.png
    '';

    meta = {
      description = "Experimental Nintendo Switch 2 emulator derived from Eden, Yuzu and Sudachi (upstream AppImage)";
      homepage = "https://github.com/Djihads80/Eglantine";
      mainProgram = pname;
      platforms = ["x86_64-linux"];
    };
  }
