{
  pkgs,
  callPackage,
  ...
}: let
  sources = callPackage ../../_sources/generated.nix {};
  inherit (pkgs) lib stdenv autoPatchelfHook makeWrapper unzip copyDesktopItems makeDesktopItem;

  # Godot dlopens its display, graphics and audio backends at runtime, so
  # autoPatchelf never sees them.
  runtimeLibs = with pkgs; [
    alsa-lib
    dbus
    fontconfig
    icu
    libdecor
    libGL
    libpulseaudio
    libx11
    libxcursor
    libxext
    libxi
    libxinerama
    libxkbcommon
    libxrandr
    libxrender
    openssl
    udev
    vulkan-loader
    wayland
  ];
in
  stdenv.mkDerivation {
    pname = "gdsdecomp";
    inherit (sources.gdsdecomp) version src;

    sourceRoot = ".";

    nativeBuildInputs = [autoPatchelfHook makeWrapper unzip copyDesktopItems];

    buildInputs = [stdenv.cc.cc.lib];

    installPhase = ''
      runHook preInstall

      # Godot looks for the .pck next to the real executable, not the wrapper.
      install -Dm755 gdre_tools.x86_64 $out/libexec/gdsdecomp/gdre_tools.x86_64
      install -Dm644 gdre_tools.pck $out/libexec/gdsdecomp/gdre_tools.pck
      install -Dm755 libGodotMonoDecompNativeAOT.so $out/libexec/gdsdecomp/libGodotMonoDecompNativeAOT.so

      makeWrapper $out/libexec/gdsdecomp/gdre_tools.x86_64 $out/bin/gdre_tools \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runtimeLibs}

      install -Dm644 ${sources.gdsdecomp-icon.src} $out/share/icons/hicolor/64x64/apps/gdsdecomp.png

      runHook postInstall
    '';

    desktopItems = [
      (makeDesktopItem {
        name = "gdsdecomp";
        desktopName = "GDRE Tools";
        exec = "gdre_tools";
        comment = "Godot reverse engineering tools";
        icon = "gdsdecomp";
        categories = ["Development"];
      })
    ];

    meta = with lib; {
      description = "Godot reverse engineering tools for recovering projects from exported games";
      homepage = "https://github.com/GDRETools/gdsdecomp";
      sourceProvenance = with sourceTypes; [binaryNativeCode];
      license = licenses.mit;
      platforms = ["x86_64-linux"];
      mainProgram = "gdre_tools";
    };
  }
