{
  lib,
  stdenv,
  makeWrapper,
  wrapGAppsHook3,
  pkg-config,
  gtkmm3,
  curl,
  nlohmann_json,
  callPackage,
}: let
  sources = callPackage ../../_sources/generated.nix {};
in
  stdenv.mkDerivation rec {
    pname = "monkeylauncher";
    version = sources.monkeylauncher.version;
    src = sources.monkeylauncher.src;

    nativeBuildInputs = [makeWrapper wrapGAppsHook3 pkg-config];
    buildInputs = [gtkmm3 curl nlohmann_json];

    installPhase = ''
        runHook preInstall

        mkdir -p $out/{bin,share/{monkeylauncher,applications,icons/hicolor/256x256/apps}}

        # GUI, compiled from cpp/ by the Makefile's default target
        install -Dm755 build/monkeylauncher $out/bin/monkeylauncher

        # CLI
        cp src/MonkeyLauncherCLI.sh $out/share/monkeylauncher/
        makeWrapper ${stdenv.shell} $out/bin/monkeylauncher-cli \
          --add-flags "$out/share/monkeylauncher/MonkeyLauncherCLI.sh"

        # Icon
        cp src/logo.png $out/share/icons/hicolor/256x256/apps/monkeylauncher.png

        # Desktop entry
        cat > $out/share/applications/monkeylauncher.desktop <<EOF
      [Desktop Entry]
      Name=MonkeyLauncher
      Comment=Wine/Proton game launcher
      Exec=$out/bin/monkeylauncher
      Icon=monkeylauncher
      Type=Application
      Categories=Game;
      Terminal=false
      StartupNotify=true
      EOF

        runHook postInstall
    '';

    meta = with lib; {
      description = "A launcher for online-fix Windows games on Linux, built on top of umu-launcher and Proton";
      homepage = "https://github.com/SaruM4N3/MonkeyLauncher";
      license = licenses.free;
      maintainers = [];
      platforms = platforms.linux;
    };
  }
