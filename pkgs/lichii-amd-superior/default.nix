{
  appimageTools,
  fetchurl,
  makeWrapper,
  symlinkJoin,
}: let
  pname = "lichii-amd-superior";

  # CheezerWheezer's "Lichii AMD Superior": a Lichii fork tuned for AMD GPUs. It
  # saves compiled shaders to disk (VK_KHR_pipeline_binary), which AMD's driver
  # otherwise discards each boot, and accepts shader packs built on any GPU. Built
  # on zortos293/Lichii build 117 with conongnang's oot-amd-perf work. It still
  # brands as "Lichii", so it shares the pooled nx2 data store. All upstream builds
  # are prereleases nvfetcher skips, so run ./update.sh to refresh `version` and
  # `hash` to the newest release by publish date that ships the PGO AppImage.
  version = "build-6";

  src = fetchurl {
    url = "https://github.com/CheezerWheezer/Lichii/releases/download/${version}/lichii-linux-x86_64-pgo.AppImage";
    hash = "sha256-LgcNScL/cBaTQ9BOgP/y/cFbKeeK4BM8Cwh+kRjZEnY=";
  };

  # The desktop entry and icon live inside the AppImage, named for zortos293's
  # Lichii; we retarget them below so this coexists with the lichii package.
  contents = appimageTools.extract {inherit pname version src;};

  # wrapType2 runs the AppImage in an FHS sandbox; its binary is $out/bin/lichii-amd-superior.
  # vulkan-loader lets the bundled app reach the NixOS GPU drivers under
  # /run/opengl-driver so Vulkan (the emulator's renderer) works. libgpg-error is
  # linked by a bundled lib but absent from appimageTools' default FHS on this
  # nixpkgs. libxcb-cursor is bundled in this build, so unlike some forks it does
  # not need xcb-util-cursor added here.
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

      # The bundled entry is named for zortos293's Lichii and runs the lichii
      # binary; retarget it at this package so it shows up as its own launcher item
      # next to the lichii package instead of colliding with it.
      install -Dm444 ${contents}/usr/share/applications/io.github.zortos293.lichii.desktop \
        $out/share/applications/${pname}.desktop
      substituteInPlace $out/share/applications/${pname}.desktop \
        --replace-warn "Name=Lichii" "Name=Lichii AMD Superior" \
        --replace-warn "Exec=lichii" "Exec=${pname}" \
        --replace-warn "Icon=io.github.zortos293.lichii" "Icon=${pname}" \
        --replace-warn "StartupWMClass=lichii" "StartupWMClass=${pname}"

      install -Dm444 ${contents}/usr/share/icons/hicolor/256x256/apps/io.github.zortos293.lichii.png \
        $out/share/icons/hicolor/256x256/apps/${pname}.png
    '';

    meta = {
      description = "Lichii AMD Superior: AMD-tuned Nintendo Switch 2 emulator fork of Lichii with on-disk shader saving (upstream AppImage)";
      homepage = "https://github.com/CheezerWheezer/Lichii";
      mainProgram = pname;
      platforms = ["x86_64-linux"];
    };
  }
