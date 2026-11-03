{
  lib,
  stdenv,
  fetchFromGitHub,
  qt6,
  zlib,
  openssl,
  pkg-config,
  copyDesktopItems,
  makeDesktopItem,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "safe-exam-browser";
  version = "0.6.0-unstable-2026-11-03";

  src = fetchFromGitHub {
    owner = "Jvr2022";
    repo = "seb-linux";
    rev = "3176207e21c065f0a7cfbc80df6dc3f25efaaeb9";
    hash = "sha256-+SxPx2ZGtOGsE/VLMKB1F0bVqBKaxDEf+8fnYW+9WG4=";
  };

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

  postPatch = ''
    # Upstream applies the exam lockdown by relaunching as root, seizing a free
    # virtual terminal and rendering to the raw framebuffer via the "linuxfb" Qt
    # platform. That plugin has no GL context, which Qt WebEngine (Chromium)
    # requires, so the exam page never renders. Keep the elevated instance inside
    # the user's X session on xcb instead: the lockdown window is still forced
    # fullscreen and always-on-top, but WebEngine can actually paint.
    substituteInPlace src/main.cpp \
      --replace-fail 'if (!setup_barebones_vt()) {' 'if (false) {' \
      --replace-fail 'qputenv("QT_QPA_PLATFORM", "linuxfb");' '/* linuxfb VT kiosk disabled: stay in the xcb session */'

    # pkexec scrubs the environment, so the root relaunch only sees the variables
    # the app explicitly forwards. A Nix-built Qt app finds its platform plugins
    # and the QtWebEngineProcess helper through variables set by wrapQtAppsHook,
    # so those have to ride along or the root instance cannot start.
    substituteInPlace src/main.cpp \
      --replace-fail 'appendPkexecEnvironmentVariable(pkexecArgs, "QT_QPA_PLATFORM");' 'appendPkexecEnvironmentVariable(pkexecArgs, "QT_QPA_PLATFORM");
            appendPkexecEnvironmentVariable(pkexecArgs, "QT_PLUGIN_PATH");
            appendPkexecEnvironmentVariable(pkexecArgs, "QT_QPA_PLATFORM_PLUGIN_PATH");
            appendPkexecEnvironmentVariable(pkexecArgs, "QML2_IMPORT_PATH");
            appendPkexecEnvironmentVariable(pkexecArgs, "QML_IMPORT_PATH");
            appendPkexecEnvironmentVariable(pkexecArgs, "QTWEBENGINEPROCESS_PATH");
            appendPkexecEnvironmentVariable(pkexecArgs, "QTWEBENGINE_RESOURCES_PATH");
            appendPkexecEnvironmentVariable(pkexecArgs, "QTWEBENGINE_LOCALES_PATH");
            appendPkexecEnvironmentVariable(pkexecArgs, "QTWEBENGINE_DICTIONARIES_PATH");
            appendPkexecEnvironmentVariable(pkexecArgs, "LD_LIBRARY_PATH");
            appendPkexecEnvironmentVariable(pkexecArgs, "XDG_DATA_DIRS");
            appendPkexecEnvironmentVariable(pkexecArgs, "FONTCONFIG_FILE");
            appendPkexecEnvironmentVariable(pkexecArgs, "FONTCONFIG_PATH");'
  '';

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
