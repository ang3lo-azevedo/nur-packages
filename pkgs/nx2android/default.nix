{
  lib,
  stdenv,
  python3,
  qt6,
  callPackage,
  makeWrapper,
  copyDesktopItems,
  makeDesktopItem,
}: let
  sources = callPackage ../../_sources/generated.nix {};

  pythonEnv = python3.withPackages (ps:
    with ps; [
      pyside6
      lz4
      capstone
      pillow
      fonttools
      pyyaml
      pycryptodome
    ]);
in
  stdenv.mkDerivation {
    pname = "nx2android";
    version = sources.nx2android.version;

    src = sources.nx2android.src;

    # wrapQtAppsHook only sets qtWrapperArgs here; the bin entries are our own
    # Python wrappers, so wrap them by hand with those args.
    nativeBuildInputs = [qt6.wrapQtAppsHook makeWrapper copyDesktopItems];
    # wrapQtAppsHook reads qtPluginPrefix from qtbase to build qtWrapperArgs.
    buildInputs = [qt6.qtbase];
    dontWrapQtApps = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/nx2android $out/bin
      cp -r . $out/share/nx2android/
      # Dev-only trees the porter never reads at runtime.
      rm -rf $out/share/nx2android/{docs,.github,.githooks,.claude}

      install -Dm644 gui/icon.png $out/share/icons/hicolor/256x256/apps/nx2android.png

      # python -m gui is the GUI; python -m porter is the command-line porter.
      makeWrapper ${pythonEnv}/bin/python $out/bin/nx2android \
        --add-flags "-m gui" \
        --prefix PYTHONPATH : $out/share/nx2android \
        "''${qtWrapperArgs[@]}"
      makeWrapper ${pythonEnv}/bin/python $out/bin/nx2android-porter \
        --add-flags "-m porter" \
        --prefix PYTHONPATH : $out/share/nx2android

      runHook postInstall
    '';

    desktopItems = [
      (makeDesktopItem {
        name = "nx2android";
        exec = "nx2android";
        icon = "nx2android";
        desktopName = "nx2android";
        comment = "Port your own Nintendo Switch games to Android";
        categories = ["Game" "Utility"];
      })
    ];

    meta = with lib; {
      description = "Compatibility layer for porting Switch games to Android, one game at a time";
      homepage = "https://github.com/shirai91/nx2android";
      license = licenses.mit;
      maintainers = [];
      mainProgram = "nx2android";
      platforms = platforms.linux;
    };
  }
