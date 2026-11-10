{
  appimageTools,
  fetchurl,
  makeWrapper,
  symlinkJoin,
}: let
  pname = "orchid";

  # Upstream's prebuilt nx2 AppImage (PGO build). Kept alongside eglantine and
  # lichii so the Eden-derived nx2 emulators can be compared. Releases use plain
  # semver tags (v*) with a version-templated asset name, so the URL below
  # rebuilds cleanly from `version`. Run ./update.sh to refresh `version` and
  # `hash` to the newest release by publish date from
  # https://github.com/MythosOfs/Orchid/releases.
  version = "v0.9.5";

  src = fetchurl {
    url = "https://github.com/MythosOfs/Orchid/releases/download/${version}/orchid-${version}-linux-x86_64-pgo.AppImage";
    hash = "sha256-aNNuPLgGHBnx/Rv6onpN/9G3df1JwLd9xXD2HEpBD7U=";
  };

  # The desktop entry (Exec=orchid already) and icon live inside the AppImage.
  contents = appimageTools.extract {inherit pname version src;};

  # wrapType2 runs the AppImage in an FHS sandbox; its binary is $out/bin/orchid.
  # vulkan-loader lets the bundled app reach the NixOS GPU drivers under
  # /run/opengl-driver so Vulkan (the emulator's main renderer) works. libgpg-error
  # is linked by a bundled lib but, unlike libgcrypt, is absent from appimageTools'
  # default FHS on this nixpkgs, so the AppImage fails to load without it.
  # xcb-util-cursor provides libxcb-cursor.so.0, which this build's Qt (6.5+)
  # requires to load its xcb platform plugin; without it the plugin init fails and
  # the app aborts.
  fhs = appimageTools.wrapType2 {
    inherit pname version src;
    extraPkgs = pkgs: [pkgs.vulkan-loader pkgs.libgpg-error pkgs.xcb-util-cursor];
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

      # The entry file is named for Eden upstream but already targets the orchid
      # binary and icon, so just install it under the package name.
      install -Dm444 ${contents}/usr/share/applications/dev.eden_emu.eden.desktop \
        $out/share/applications/${pname}.desktop
      install -Dm444 ${contents}/usr/share/icons/hicolor/512x512/apps/dev.orchid.orchid.png \
        $out/share/icons/hicolor/512x512/apps/dev.orchid.orchid.png
    '';

    meta = {
      description = "Very experimental Nintendo Switch 2 emulator derived from Eden, Yuzu and Sudachi (upstream AppImage)";
      homepage = "https://github.com/MythosOfs/Orchid";
      mainProgram = pname;
      platforms = ["x86_64-linux"];
    };
  }
