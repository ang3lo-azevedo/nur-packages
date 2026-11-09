{
  appimageTools,
  callPackage,
  android-tools,
  rclone,
}:
let
  sources = callPackage ../../_sources/generated.nix { };
  pname = "vrcd";
  version = sources.vrcd.version;
  src = sources.vrcd.src;

  appimageContents = appimageTools.extract {
    inherit pname version src;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraPkgs = pkgs: [
    pkgs.android-tools
    pkgs.rclone
  ];

  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/vr-cyberdeck.desktop -t $out/share/applications
    substituteInPlace $out/share/applications/vr-cyberdeck.desktop \
      --replace-fail 'Exec=AppRun --no-sandbox %U' 'Exec=vrcd %U'

    cp -r ${appimageContents}/usr/share/icons $out/share/

    ln -s $out/bin/vrcd $out/bin/vr-cyberdeck
  '';

  meta = {
    description = "VR CyberDeck: multi-OS sideloader for Android / Meta Quest devices";
    homepage = "https://github.com/DeliciousMeatPop/VRCD";
    mainProgram = "vrcd";
    platforms = [ "x86_64-linux" ];
  };
}
