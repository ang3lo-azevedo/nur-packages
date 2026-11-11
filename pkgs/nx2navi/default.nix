{
  lib,
  appimageTools,
  makeDesktopItem,
  callPackage,
  clang,
  lld,
  gcc,
  sdl3,
  libopus,
  libvpx,
  dav1d,
  zstd,
  vulkan-loader,
}: let
  sources = callPackage ../../_sources/generated.nix {};
  inherit (sources.nx2navi) version src;
  pname = "nx2navi";

  # NX2navi ships no game: the AppImage is a Linux build kit that recompiles Ocarina
  # of Time on this machine from the player's own dump. It bundles the shader
  # translator, a CPython runtime and the pinned Vulkan/VMA headers, but takes the C
  # toolchain and these libraries from the system (its AppRun checks for them and
  # otherwise prints distro install commands). On NixOS there is no system toolchain,
  # so wrap the AppImage with one.
  headerPkgs = [sdl3 libopus libvpx dav1d zstd];
  libPkgs = headerPkgs ++ [vulkan-loader gcc.cc.lib];

  extracted = appimageTools.extract {inherit pname version src;};

  desktopItem = makeDesktopItem {
    name = "nx2navi";
    exec = "nx2navi";
    icon = "nx2navi";
    desktopName = "NX2navi";
    comment = "Build and play Ocarina of Time (Switch 2) from your own dump";
    categories = ["Game"];
  };
in
  appimageTools.wrapType2 {
    inherit pname version src;

    extraPkgs = _:
      [
        # AppRun needs clang, clang++ and ld.lld on PATH; gcc gives clang the GCC
        # install it finds libstdc++ (linked static into the game) through.
        clang
        lld
        gcc
      ]
      # dev outputs put the headers at /usr/include, where AppRun checks for them by
      # path; lib outputs put the shared libraries at /usr/lib for the built game.
      ++ map lib.getDev headerPkgs
      ++ map lib.getLib libPkgs;

    # AppRun's clang is the nixpkgs wrapper, which ignores /usr/include; point it and
    # the linker at the same store paths so the compile finds what the path check saw.
    profile = ''
      export CPATH=${lib.makeSearchPathOutput "dev" "include" headerPkgs}
      export LIBRARY_PATH=${lib.makeLibraryPath libPkgs}
    '';

    extraInstallCommands = ''
      install -Dm644 ${extracted}/nx2navi.png \
        $out/share/icons/hicolor/256x256/apps/nx2navi.png
      mkdir -p $out/share/applications
      cp ${desktopItem}/share/applications/* $out/share/applications/
    '';

    meta = with lib; {
      description = "Static recompilation of The Legend of Zelda: Ocarina of Time for Switch 2 (Linux build kit)";
      longDescription = ''
        NX2navi recompiles Ocarina of Time (Switch 2, game 1.1.1) into a native Vulkan
        executable from the player's own legally dumped game files. No game content
        ships with it. Run without arguments it opens a window to install, update and
        play; or build from the command line against a .nup packed with the nup tool:
          nx2navi /path/to/game.nup ~/Games/Ocarina
        then start the result with its own play.sh. The first build installs zbic with
        pip and downloads NVIDIA DLSS on machines with NVIDIA's driver.
      '';
      homepage = "https://github.com/tangerineturtle1/NX2navi";
      # MIT base import plus an all-rights-reserved LICENSE-ADDITIONS: treat as unfree.
      license = licenses.unfree;
      maintainers = [];
      mainProgram = "nx2navi";
      platforms = ["x86_64-linux"];
    };
  }
