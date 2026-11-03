{
  lib,
  appimageTools,
  fetchurl,
  pkgs,
}: let
  pname = "safe-exam-browser";
  version = "0.6.0";

  src = fetchurl {
    url = "https://github.com/Jvr2022/seb-linux/releases/download/v${version}/safe-exam-browser-qt-x86_64.AppImage";
    sha256 = "sha256-dACqss898wbQ2IGXd/gRNW1dJGuAW4RbZXLT4NES3as=";
  };

  # Extract the AppImage instead of running it through appimageTools.wrapType2.
  # wrapType2 executes everything inside a bubblewrap FHS sandbox, i.e. an
  # unprivileged user namespace. Safe Exam Browser applies its exam lockdown by
  # relaunching itself through polkit's pkexec to gain root; inside an
  # unprivileged user namespace a setuid pkexec can never become root, so the
  # lockdown aborts with "pkexec must be setuid root". Running the binaries
  # natively on the host keeps pkexec pointed at the host's real setuid wrapper,
  # which is the only way the lockdown can actually elevate.
  appimageContents = appimageTools.extract {
    inherit pname version src;
  };
in
  pkgs.stdenv.mkDerivation {
    inherit pname version;

    dontUnpack = true;

    nativeBuildInputs = with pkgs; [
      autoPatchelfHook
      makeWrapper
    ];

    buildInputs = with pkgs;
      [
        stdenv.cc.cc.lib
        zlib
        openssl
        glib
        dbus
        fontconfig
        freetype
        nss
        nspr
        expat
        libdrm
        libxkbcommon
        libgcrypt
        libgpg-error
        alsa-lib
        cups
        pango
        cairo
        gdk-pixbuf
        atk
        at-spi2-core
        at-spi2-atk
        gtk3
        libxml2
        libxslt
        libGL
        libglvnd
        krb5
        e2fsprogs
        libpulseaudio
        harfbuzz
        libdbusmenu
      ]
      ++ (with pkgs.xorg; [
        libX11
        libxcb
        libXcomposite
        libXdamage
        libXext
        libXfixes
        libXrandr
        libXrender
        libXtst
        libXi
        libXcursor
        libXScrnSaver
        libxshmfence
        xcbutil
        xcbutilimage
        xcbutilkeysyms
        xcbutilrenderutil
        xcbutilwm
      ]);

    # libudev is dlopened by Qt for device discovery, so it has to be forced
    # onto every patched binary's runpath rather than resolved from NEEDED.
    runtimeDependencies = [(lib.getLib pkgs.systemd)];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/opt/seb
      cp -r ${appimageContents}/usr $out/opt/seb/usr
      chmod -R u+w $out/opt/seb

      install -Dm444 ${appimageContents}/safe-exam-browser.desktop \
        $out/share/applications/safe-exam-browser.desktop || true
      install -Dm444 ${appimageContents}/safe-exam-browser.png \
        $out/share/icons/hicolor/256x256/apps/safe-exam-browser.png || true

      # The bundled Qt only ships the xcb platform plugin, so force xcb instead
      # of letting it try (and fail) to use Wayland under Wayland compositors.
      # QTWEBENGINE_DISABLE_SANDBOX lets the Chromium render process start when
      # the lockdown relaunches the browser as root, where the namespace sandbox
      # is refused.
      makeWrapper $out/opt/seb/usr/bin/safe-exam-browser $out/bin/safe-exam-browser \
        --set QT_QPA_PLATFORM xcb \
        --set QTWEBENGINE_DISABLE_SANDBOX 1 \
        --unset QT_STYLE_OVERRIDE \
        --unset QT_QPA_PLATFORMTHEME

      runHook postInstall
    '';

    meta = with lib; {
      description = "Community-driven Linux edition of Safe Exam Browser (Qt WebEngine)";
      homepage = "https://github.com/Jvr2022/seb-linux";
      license = licenses.mpl20;
      mainProgram = "safe-exam-browser";
      platforms = platforms.linux;
    };
  }
