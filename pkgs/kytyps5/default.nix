{
  lib,
  stdenv,
  callPackage,
  autoPatchelfHook,
  makeWrapper,
  copyDesktopItems,
  makeDesktopItem,
  alsa-lib,
  brotli,
  dbus,
  fontconfig,
  freetype,
  glib,
  gtk3,
  krb5,
  libdecor,
  libdrm,
  libglvnd,
  libpulseaudio,
  libx11,
  libxcb,
  libxcb-cursor,
  libxcb-image,
  libxcb-keysyms,
  libxcb-render-util,
  libxcb-util,
  libxcb-wm,
  libxcursor,
  libxext,
  libxfixes,
  libxi,
  libxkbcommon,
  libxrandr,
  libxscrnsaver,
  libxtst,
  openssl,
  pipewire,
  systemdLibs,
  vulkan-loader,
  wayland,
  zlib,
  zstd,
}: let
  sources = callPackage ../../_sources/generated.nix {};

  runtimeLibs = [
    alsa-lib
    dbus
    gtk3
    libdecor
    libglvnd
    libpulseaudio
    libx11
    libxcursor
    libxext
    libxfixes
    libxi
    libxkbcommon
    libxrandr
    libxscrnsaver
    libxtst
    openssl
    pipewire
    systemdLibs
    vulkan-loader
    wayland
  ];
in
  stdenv.mkDerivation {
    pname = "kytyps5";
    inherit (sources.kytyps5) version src;

    sourceRoot = ".";
    preferLocalBuild = true;

    nativeBuildInputs = [
      autoPatchelfHook
      makeWrapper
      copyDesktopItems
    ];

    # SDL3 embeds FDO_DLOPEN_METADATA (.note.dlopen), so autoPatchelf checks
    # its optional/backend libraries directly alongside DT_NEEDED entries.
    buildInputs = [
      stdenv.cc.cc.lib
      alsa-lib
      brotli
      dbus
      fontconfig
      freetype
      glib
      krb5
      libdecor
      libdrm
      libglvnd
      libpulseaudio
      libx11
      libxcb
      libxcb-cursor
      libxcb-image
      libxcb-keysyms
      libxcb-render-util
      libxcb-util
      libxcb-wm
      libxcursor
      libxext
      libxfixes
      libxi
      libxkbcommon
      libxrandr
      libxscrnsaver
      libxtst
      vulkan-loader
      wayland
      zlib
      zstd
    ];

    # Optional SDL3 dlopen metadata entries (legacy GLESv1 CM and Steamworks API).
    autoPatchelfIgnoreMissingDeps = [
      "libGLES_CM.so.1"
      "libsteam_api.so"
    ];

    dontConfigure = true;
    dontBuild = true;

    preFixup = ''
      addAutoPatchelfSearchPath $out/opt/kytyps5/lib
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/opt/kytyps5 $out/bin
      cp -a kyty_launcher kyty_emulator kyty_updater qt.conf lib plugins assets licenses $out/opt/kytyps5/
      chmod +x $out/opt/kytyps5/kyty_launcher $out/opt/kytyps5/kyty_emulator $out/opt/kytyps5/kyty_updater

      makeWrapper $out/opt/kytyps5/kyty_launcher $out/bin/kyty_launcher \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath runtimeLibs}" \
        --set-default MESA_VK_DEVICE_SELECT "1002:7590" \
        --set-default DRI_PRIME "1"

      makeWrapper $out/opt/kytyps5/kyty_emulator $out/bin/kyty_emulator \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath runtimeLibs}" \
        --set-default MESA_VK_DEVICE_SELECT "1002:7590" \
        --set-default DRI_PRIME "1"

      ln -s kyty_launcher $out/bin/kytyps5

      install -Dm444 ${sources.kytyps5-icon.src} $out/share/icons/hicolor/scalable/apps/kytyps5.svg

      runHook postInstall
    '';

    desktopItems = [
      (makeDesktopItem {
        name = "kytyps5";
        desktopName = "KytyPS5";
        exec = "kytyps5";
        icon = "kytyps5";
        comment = "PlayStation 5 compatibility layer and emulator";
        categories = [
          "Game"
          "Emulator"
        ];
        startupWMClass = "kyty_launcher";
      })
    ];

    meta = with lib; {
      description = "PlayStation 5 translation layer and emulator (KytyPS5)";
      homepage = "https://github.com/KytyPS5/KytyPS5";
      sourceProvenance = with sourceTypes; [binaryNativeCode];
      license = licenses.gpl2Only;
      platforms = ["x86_64-linux"];
      mainProgram = "kytyps5";
    };
  }
