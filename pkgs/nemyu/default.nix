{
  appimageTools,
  fetchurl,
  makeWrapper,
  symlinkJoin,
}: let
  pname = "nemyu";

  # Nemyu is another experimental nx2 (Switch 2) emulator, kept alongside the
  # other forks. Prebuilt linux x86_64 AppImage from the newest GitLab release
  # that ships one: newer releases are sometimes Windows-only, so run
  # ./update.sh (it picks the newest release with a linux AppImage). The GitLab
  # generic-package URL embeds the commit and pipeline id, so unlike the other
  # emulators it cannot be rebuilt from `version`: update.sh rewrites the full
  # `url` as well.
  version = "nemyu-v0.1.3";

  src = fetchurl {
    url = "https://gitlab.com/api/v4/projects/88355366/packages/generic/nemyu-linux-x86_64/0befe709f87a938b92021419c68451f7aab6a003-17685457776/nemyu-nemyu-v0.1.3-linux-x86_64.AppImage";
    hash = "sha256-UjsSHH1E1MPyzRGHmiGPYUrMBiItNppTMouQ4YSEEo8=";
  };

  contents = appimageTools.extract {inherit pname version src;};

  # wrapType2 runs the AppImage in an FHS sandbox; its binary is $out/bin/nemyu.
  # vulkan-loader reaches the NixOS GPU drivers under /run/opengl-driver so Vulkan
  # works; libgpg-error is linked by a bundled lib but missing from the default
  # FHS; xcb-util-cursor provides libxcb-cursor.so.0 that newer Qt (6.5+) needs to
  # load its xcb platform plugin.
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
      # the iGPU and a manual env still wins. Force xcb so it runs through XWayland
      # (the AppImage bundles no qtwayland plugin).
      wrapProgram $out/bin/${pname} \
        --set QT_QPA_PLATFORM xcb \
        --set-default MESA_VK_DEVICE_SELECT 1002:7590 \
        --set-default DRI_PRIME 1

      # Nemyu's bundled desktop entry and icon paths are not stable across
      # releases, so discover them rather than hardcoding, and retarget Exec/Icon
      # at this package.
      desktop=$(find ${contents} -maxdepth 3 -name '*.desktop' | head -n1 || true)
      if [ -n "$desktop" ]; then
        install -Dm444 "$desktop" $out/share/applications/${pname}.desktop
        chmod u+w $out/share/applications/${pname}.desktop
        sed -i \
          -e 's|^Exec=.*|Exec=${pname} %U|' \
          -e 's|^Icon=.*|Icon=${pname}|' \
          $out/share/applications/${pname}.desktop
      fi
      icon=$(find ${contents} -path '*/icons/*' -name '*.png' -printf '%s %p\n' 2>/dev/null | sort -n | tail -n1 | cut -d' ' -f2- || true)
      [ -n "$icon" ] || icon=$(find ${contents} -maxdepth 2 -name '*.png' | head -n1 || true)
      if [ -n "$icon" ]; then
        install -Dm444 "$icon" $out/share/icons/hicolor/512x512/apps/${pname}.png
      fi
    '';

    meta = {
      description = "Nemyu: an experimental Nintendo Switch 2 emulator (upstream AppImage)";
      homepage = "https://gitlab.com/nemyu-emulator/nemyu";
      mainProgram = pname;
      platforms = ["x86_64-linux"];
    };
  }
