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

  appimageContents = appimageTools.extract {
    inherit pname version src;
  };
in
  appimageTools.wrapType2 {
    inherit pname version src;

    extraPkgs = pkgs: [
      pkgs.libgpg-error
      pkgs.libgcrypt
      (pkgs.writeShellScriptBin "pkexec" ''
        exec /run/wrappers/bin/pkexec "$@"
      '')
    ];

    extraInstallCommands = ''
      install -m 444 -D ${appimageContents}/safe-exam-browser.desktop -t $out/share/applications || true
      mkdir -p $out/share/icons/hicolor/256x256/apps
      install -m 444 ${appimageContents}/safe-exam-browser.png $out/share/icons/hicolor/256x256/apps/safe-exam-browser.png || true

      # The FHS environment is executed through bubblewrap. Point the sandbox
      # wrapper at the NixOS-managed setuid wrapper (/run/wrappers/bin/bwrap)
      # so bubblewrap runs with real privileges. When bubblewrap runs
      # unprivileged, it falls back to an unprivileged user namespace in which
      # setuid binaries (polkit's pkexec) can no longer gain root, which made
      # Safe Exam Browser abort with "pkexec must be setuid root".
      sed -i "s|${pkgs.bubblewrap}/bin/bwrap|/run/wrappers/bin/bwrap|" $out/bin/safe-exam-browser

      # The bundled Qt only ships the xcb platform plugin, so force xcb instead of
      # letting it try (and fail) to use Wayland under Wayland compositors.
      mv $out/bin/safe-exam-browser $out/bin/.safe-exam-browser-wrapped
      cat > $out/bin/safe-exam-browser <<WRAPPER
#!/bin/sh
exec env -u QT_STYLE_OVERRIDE -u QT_QPA_PLATFORMTHEME QT_QPA_PLATFORM=xcb PATH="/run/wrappers/bin:$PATH" "$out/bin/.safe-exam-browser-wrapped" "\$@"
WRAPPER
      chmod +x $out/bin/safe-exam-browser
    '';

    meta = with lib; {
      description = "Community-driven Linux edition of Safe Exam Browser (Qt WebEngine)";
      homepage = "https://github.com/Jvr2022/seb-linux";
      license = licenses.mpl20;
      mainProgram = "safe-exam-browser";
      platforms = platforms.linux;
    };
  }