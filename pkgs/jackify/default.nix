{pkgs, ...}: let
  sources = pkgs.callPackage ../../_sources/generated.nix {};
  pname = "jackify";
  version = sources.jackify.version;
  src = sources.jackify.src;
  # wrapType2 never exposes the AppImage's bundled icon, so pull it from the
  # extracted contents and install it under the Icon= name the entry references.
  extracted = pkgs.appimageTools.extract {inherit pname version src;};
in
  pkgs.appimageTools.wrapType2 {
    inherit pname version src;

    extraPkgs = pkgs: with pkgs; [zstd];

    extraInstallCommands = ''
      install -Dm644 ${extracted}/usr/share/icons/hicolor/256x256/apps/com.jackify.app.png \
        $out/share/icons/hicolor/256x256/apps/com.jackify.app.png

      mkdir -p $out/share/applications
      cp ${pkgs.makeDesktopItem {
        name = "jackify";
        exec = "jackify %u";
        icon = "com.jackify.app";
        desktopName = "Jackify";
        comment = "Wabbajack modlist manager for Linux";
        categories = ["Game" "Utility"];
        mimeTypes = ["x-scheme-handler/jackify" "x-scheme-handler/nxm"];
      }}/share/applications/* $out/share/applications/
    '';

    meta = {
      description = "Simplifying Wabbajack modlist installation and configuration on Linux";
      longDescription = ''
        Jackify installs and configures Wabbajack modlists on Linux and Steam Deck,
        handling downloading, Steam shortcut creation, Proton prefix setup, and
        post-install configuration through a GUI and CLI.
      '';
      homepage = "https://github.com/Omni-guides/Jackify";
    };
  }
