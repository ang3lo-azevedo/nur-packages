{
  lib,
  stdenv,
  callPackage,
  qt6,
  zlib,
  openssl,
  pkg-config,
  copyDesktopItems,
  makeDesktopItem,
  
  # When true, neuter the anti-cheat "Multiple displays detected" check so the
  # exam shell runs on a multi-monitor setup. Set to false to restore upstream's
  # single-display enforcement.
  allowMultipleDisplays ? true,
  
  # When true, compute the SEB Config Key with the official algorithm
  # (dictionary keys sorted case-insensitively and recursively, "originatorVersion"
  # removed) instead of upstream's QJsonObject ordering, which sorts keys
  # case-sensitively and does not match the hash Moodle computes server-side. Set
  # to false to keep upstream's computation.
  standardConfigKey ? true,
}: let
  sources = callPackage ../../_sources/generated.nix {};
in
stdenv.mkDerivation (finalAttrs: {
  pname = "safe-exam-browser";
  inherit (sources.safe-exam-browser) version src;

  nativeBuildInputs = [
    qt6.qmake
    qt6.wrapQtAppsHook
    pkg-config
    copyDesktopItems
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtwebengine
    qt6.qtdeclarative
    qt6.qtsvg
    zlib
    openssl
  ];

  patches =
    [
      # Keep the elevated lockdown instance in the user's xcb session instead of
      # seizing a bare VT with the "linuxfb" Qt platform (no GL context, so Qt
      # WebEngine never paints the exam), and forward the Qt/WebEngine env
      # variables that wrapQtAppsHook sets through pkexec, which otherwise scrubs
      # them and leaves the root relaunch unable to find its plugins.
      ./run-in-session.patch
    ]
    
    # Make the anti-cheat "Multiple displays detected" check (not configurable
    # through the .seb file) a no-op so SEB runs on multi-monitor setups.
    ++ lib.optional allowMultipleDisplays ./allow-multiple-displays.patch
    
    # Compute the SEB Config Key with the official algorithm (keys sorted
    # case-insensitively and recursively, "originatorVersion" removed) so the
    # ConfigKeyHash header matches what Moodle computes server-side.
    ++ lib.optional standardConfigKey ./standard-config-key.patch;

  # force_qtwebengine makes qmake fail loudly if the WebEngine Qt modules are
  # missing instead of silently falling back to the WebKitGTK engine.
  # SEB_DEV_BYPASS_OPTION exposes an opt-in "--dev-bypass" flag (lockdown off)
  # for troubleshooting; it does not change the default behaviour.
  qmakeFlags = [
    "CONFIG+=force_qtwebengine"
    "DEFINES+=SEB_DEV_BYPASS_OPTION=1"
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 bin/safe-exam-browser $out/bin/safe-exam-browser
    install -Dm644 assets/icons/safe-exam-browser.png \
      $out/share/icons/hicolor/256x256/apps/safe-exam-browser.png

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "safe-exam-browser";
      desktopName = "Safe Exam Browser";
      comment = "Launch secure exams, open .seb files, and handle seb:// links";
      exec = "safe-exam-browser %u";
      icon = "safe-exam-browser";
      terminal = false;
      categories = ["Education" "Network"];
      mimeTypes = [
        "application/x-seb"
        "x-scheme-handler/seb"
        "x-scheme-handler/sebs"
      ];
      startupWMClass = "Safe Exam Browser";
    })
  ];

  meta = with lib; {
    description = "Community-driven Linux edition of Safe Exam Browser (Qt WebEngine)";
    homepage = "https://github.com/Jvr2022/seb-linux";
    license = licenses.mpl20;
    mainProgram = "safe-exam-browser";
    platforms = platforms.linux;
  };
})
