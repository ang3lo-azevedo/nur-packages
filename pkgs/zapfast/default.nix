{pkgs, ...}: let
  sources = pkgs.callPackage ../../_sources/generated.nix {};

  # The GUI dlopens its Wayland, X11 and GL libraries at run time
  runtimeLibs = with pkgs; [
    libxkbcommon
    wayland
    libGL
    libx11
    libxcursor
    libxi
    libxrandr
  ];
in
  # Mirrors the package in upstream's flake.nix, built from the release nvfetcher tracks
  pkgs.rustPlatform.buildRustPackage {
    pname = "zapfast";
    version = sources.zapfast.version;

    src = sources.zapfast.src;

    cargoLock = sources.zapfast.cargoLock."Cargo.lock";

    nativeBuildInputs = with pkgs; [
      pkg-config
      cmake
      perl
      makeWrapper
    ];
    buildInputs = with pkgs; [
      alsa-lib
      libGL
      libx11
    ];

    ZAPFAST_TEST_RTL_FONT = "${pkgs.dejavu_fonts}/share/fonts/truetype/DejaVuSans.ttf";

    postInstall = ''
      install -Dm644 packaging/applications/zapfast.desktop \
        $out/share/applications/zapfast.desktop
      install -Dm644 packaging/icons/zapfast.svg \
        $out/share/icons/hicolor/scalable/apps/zapfast.svg
      install -Dm644 contrib/omarchy/zapfast.json.tpl \
        $out/share/zapfast/omarchy/zapfast.json.tpl
      install -Dm755 contrib/omarchy/zapfast-theme \
        $out/share/zapfast/omarchy/zapfast-theme
    '';

    postFixup = ''
      wrapProgram $out/bin/zapfast \
        --prefix LD_LIBRARY_PATH : ${pkgs.lib.makeLibraryPath runtimeLibs}
    '';

    meta = {
      description = "Fast native WhatsApp client";
      homepage = "https://zapfast.rocks";
      license = with pkgs.lib.licenses; [mit gpl2Only];
      mainProgram = "zapfast";
      platforms = pkgs.lib.platforms.linux;
    };
  }
