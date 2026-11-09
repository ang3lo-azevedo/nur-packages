{
  appimageTools,
  fetchurl,
  makeWrapper,
  symlinkJoin,
}: let
  pname = "smiley-eglantine";

  # SmileyTatsu's Eglantine fork (distinct from Djihads80's, which is the
  # `eglantine` package). It still brands itself "Eglantine" and ships the same
  # prebuilt nx2 AppImage (PGO build), so internally it uses the `eglantine` data
  # dir and shares the pooled store with the other forks. All upstream builds are
  # prereleases nvfetcher skips, so run ./update.sh to refresh `version` and
  # `hash` to the newest release by publish date that ships the PGO AppImage.
  # Upstream tags builds build-NN and every stable build ships
  # eglantine-linux-x86_64-pgo.AppImage, so the URL templates off the tag.
  version = "branch-smileytatsu-dev-experimental-merge-74dc0c7d";

  src = fetchurl {
    url = "https://github.com/SmileyTatsu/Eglantine/releases/download/${version}/eglantine-linux-x86_64-pgo.AppImage";
    hash = "sha256-2XLMq1FFqNes0dk9AVIJ51qixzdapj4ff9kHJZuCkW4=";
  };

  # The desktop entry and icon live inside the AppImage, both named for the
  # eglantine binary; we retarget them below so this coexists with the eglantine
  # package instead of colliding with it.
  contents = appimageTools.extract {inherit pname version src;};

  # wrapType2 runs the AppImage in an FHS sandbox; its binary is $out/bin/smiley-eglantine.
  # vulkan-loader lets the bundled app reach the NixOS GPU drivers under
  # /run/opengl-driver so Vulkan (the emulator's main renderer) works. libgpg-error
  # is linked by a bundled lib but, unlike libgcrypt, is absent from appimageTools'
  # default FHS on this nixpkgs, so the AppImage fails to load without it. Like the
  # eglantine package (same Qt lineage) it does not need xcb-util-cursor.
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
      # the eglantine package instead of colliding with it.
      install -Dm444 ${contents}/usr/share/applications/dev.eglantine.eglantine.desktop \
        $out/share/applications/${pname}.desktop
      substituteInPlace $out/share/applications/${pname}.desktop \
        --replace-warn "Name=Eglantine" "Name=Eglantine (SmileyTatsu)" \
        --replace-warn "Exec=eglantine" "Exec=${pname}" \
        --replace-warn "Icon=dev.eglantine.eglantine" "Icon=${pname}" \
        --replace-warn "StartupWMClass=eglantine" "StartupWMClass=${pname}"

      install -Dm444 ${contents}/usr/share/icons/hicolor/512x512/apps/dev.eglantine.eglantine.png \
        $out/share/icons/hicolor/512x512/apps/${pname}.png
    '';

    meta = {
      description = "Experimental Nintendo Switch 2 emulator (SmileyTatsu's Eglantine fork, derived from Eden, Yuzu and Sudachi; upstream AppImage)";
      homepage = "https://github.com/SmileyTatsu/Eglantine";
      mainProgram = pname;
      platforms = ["x86_64-linux"];
    };
  }
