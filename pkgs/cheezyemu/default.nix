{
  appimageTools,
  fetchurl,
  makeWrapper,
  symlinkJoin,
}:
let
  pname = "cheezyemu";

  # CheezerWheezer's "CheezyEmu": a Nintendo Switch and Switch 2 emulator fork
  # tuned for AMD GPUs (FSR 4, AMD frame generation, saved compiled shaders).
  # Run ./update.sh to refresh `version` and `hash` to the newest release.
  version = "build-10";

  src = fetchurl {
    url = "https://github.com/CheezerWheezer/CheezyEmu/releases/download/${version}/cheezyemu-linux-x86_64-pgo.AppImage";
    hash = "sha256-ziwKvguNgKvkYFcP2nw/cL6N6gSey21+AnF17Sx8wzg=";
  };

  contents = appimageTools.extract { inherit pname version src; };

  fhs = appimageTools.wrapType2 {
    inherit pname version src;
    extraPkgs = pkgs: [
      pkgs.vulkan-loader
      pkgs.libgpg-error
    ];
  };
in
symlinkJoin {
  name = "${pname}-${version}";
  paths = [ fhs ];
  nativeBuildInputs = [ makeWrapper ];

  postBuild = ''
    # Offload to the AMD eGPU (Navi 44, RX 9060 XT, 1002:7590) for Vulkan, with
    # DRI_PRIME for any GL path. --set-default so an unplugged eGPU falls back to
    # the iGPU and a manual env still wins.
    wrapProgram $out/bin/${pname} \
      --set-default MESA_VK_DEVICE_SELECT 1002:7590 \
      --set-default DRI_PRIME 1

    install -Dm444 ${contents}/io.github.cheezerwheezer.cheezyemu.desktop \
      $out/share/applications/io.github.cheezerwheezer.cheezyemu.desktop

    install -Dm444 ${contents}/usr/share/icons/hicolor/256x256/apps/io.github.cheezerwheezer.cheezyemu.png \
      $out/share/icons/hicolor/256x256/apps/io.github.cheezerwheezer.cheezyemu.png
  '';

  meta = {
    description = "CheezyEmu: AMD-tuned Nintendo Switch and Switch 2 emulator (upstream AppImage)";
    homepage = "https://github.com/CheezerWheezer/CheezyEmu";
    mainProgram = pname;
    platforms = [ "x86_64-linux" ];
  };
}
