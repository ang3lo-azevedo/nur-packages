{
  appimageTools,
  fetchurl,
  makeWrapper,
  symlinkJoin,
}: let
  pname = "eglantine";

  # Upstream's prebuilt nx2 AppImage. All upstream builds are prereleases
  # nvfetcher skips, so run ./update.sh to refresh `version`, `url` and `hash`
  # to the newest release by publish date. `version` is the release tag:
  # upstream publishes several kinds (build-NN, daily-*, v*, and
  # branch-<name>-<hash> feature builds) and the newest by date may be any of
  # them. The updater prefers that release's PGO AppImage (profile-guided,
  # faster) but falls back to the plain linux-x86_64 AppImage when a build does
  # not ship one, so the asset name varies and the full url is stored here
  # rather than templated off the tag.
  version = "daily-20261106";

  src = fetchurl {
    url = "https://github.com/Djihads80/Eglantine/releases/download/daily-20261106/eglantine-linux-x86_64-pgo.AppImage";
    hash = "sha256-EOESVF8/AWocECvyeeF7p+PBfwqlDrxA0vcFI9/gz0c=";
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
