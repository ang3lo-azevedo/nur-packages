{
  appimageTools,
  callPackage,
  makeWrapper,
  symlinkJoin,
}:
let
  sources = callPackage ../../_sources/generated.nix { };
  pname = "hookshot";

  # Hookshot: a static recompilation of Ocarina of Time (Switch 2 remake) that
  # runs natively with no emulator. The AppImage is the self-contained "Hookshot
  # Builder": it bundles Python/Tk, clang, a glibc sysroot, FFmpeg, SDL2 and a
  # prebuilt Vulkan backend, and builds the game on your PC from your own copy
  # (romfs/exefs or a .nup). Default launches the builder window; `--play` runs
  # the built game.
  #
  # Upstream releases are tracked automatically via nvfetcher in nvfetcher.toml.
  version = sources.hookshot.version;
  src = sources.hookshot.src;

  # The desktop entry and icon live inside the AppImage.
  contents = appimageTools.extract { inherit pname version src; };

  # wrapType2 runs the AppImage in an FHS sandbox; its binary is $out/bin/hookshot.
  # The toolchain is bundled, but the game it builds renders through Vulkan, so
  # vulkan-loader reaches the NixOS drivers under /run/opengl-driver; libGL covers
  # the GL path. The builder window is Tk, so the X11/font libraries (libX11,
  # libXext, libXrender, fontconfig, freetype) and libxkbcommon back the GUI and
  # the SDL2 game window. stdenv.cc.cc.lib and zlib back the bundled Python /
  # numpy C-extensions (like _multiarray_umath) used during game lifting.
  fhs = appimageTools.wrapType2 {
    inherit pname version src;
    extraPkgs = pkgs: [
      pkgs.stdenv.cc.cc.lib
      pkgs.zlib
      pkgs.vulkan-loader
      pkgs.libGL
      pkgs.libx11
      pkgs.libxext
      pkgs.libxrender
      pkgs.libxkbcommon
      pkgs.fontconfig
      pkgs.freetype
    ];
  };
in
symlinkJoin {
  name = "${pname}-${version}";
  paths = [ fhs ];
  nativeBuildInputs = [ makeWrapper ];

  postBuild = ''
    # Ensure 64-bit multiPkgs libraries (e.g. libfontconfig.so.1, libX11.so.6) in
    # /lib64 and /usr/lib64 are resolvable by Tkinter and bundled Python binaries
    # inside the FHS container.
    #
    # Offload the built game to the AMD eGPU (Navi 44, RX 9060 XT, 1002:7590)
    # for Vulkan, with DRI_PRIME for any GL path. --set-default so an unplugged
    # eGPU falls back to the iGPU and a manual env still wins.
    wrapProgram $out/bin/${pname} \
      --prefix LD_LIBRARY_PATH : /lib64:/usr/lib64 \
      --set-default MESA_VK_DEVICE_SELECT 1002:7590 \
      --set-default DRI_PRIME 1

    # The bundled entry runs AppRun directly; point Exec at this package's
    # wrapper (both the main launch and the "Play" action) so the launcher and
    # its Play action work from the menu.
    install -Dm444 ${contents}/hookshot-builder.desktop \
      $out/share/applications/hookshot.desktop
    substituteInPlace $out/share/applications/hookshot.desktop \
      --replace-warn "Exec=AppRun" "Exec=${pname}"

    install -Dm444 ${contents}/usr/share/icons/hicolor/256x256/apps/hookshot.png \
      $out/share/icons/hicolor/256x256/apps/hookshot.png
  '';

  meta = {
    description = "Hookshot: static recompilation of Ocarina of Time (Switch 2 remake) that runs natively (upstream AppImage builder)";
    homepage = "https://github.com/NotRexed/Hookshot";
    mainProgram = pname;
    platforms = [ "x86_64-linux" ];
  };
}
