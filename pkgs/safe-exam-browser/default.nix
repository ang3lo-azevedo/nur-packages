{
  lib,
  appimageTools,
  fetchurl,
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

    extraInstallCommands = ''
      install -m 444 -D ${appimageContents}/safe-exam-browser.desktop -t $out/share/applications || true
      mkdir -p $out/share/icons/hicolor/256x256/apps
      install -m 444 ${appimageContents}/safe-exam-browser.png $out/share/icons/hicolor/256x256/apps/safe-exam-browser.png || true
    '';

    meta = with lib; {
      description = "Community-driven Linux edition of Safe Exam Browser (Qt WebEngine)";
      homepage = "https://github.com/Jvr2022/seb-linux";
      license = licenses.mpl20;
      mainProgram = "safe-exam-browser";
      platforms = platforms.linux;
    };
  }