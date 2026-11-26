{
  appimageTools,
  fetchurl,
}: let
  pname = "discord-phoenix";
  version = "0.1.0-dev.20261123093910.gb71ec80";

  src = fetchurl {
    url = "https://dl.qwq.sh/leaks/Phoenix/discord-desktop-${version}-linux-x64.AppImage";
    hash = "sha256-iBwS1CYCaFIEO6ftFGk495O9qkTB18MA6tU2g2nqazw=";
  };

  contents = appimageTools.extract {inherit pname version src;};
in
  appimageTools.wrapType2 {
    inherit pname version src;

    extraPkgs = pkgs: [
      pkgs.vulkan-loader
      pkgs.libglvnd
      pkgs.libva
      pkgs.at-spi2-atk
      pkgs.at-spi2-core
      pkgs.libxkbcommon
    ];

    extraInstallCommands = ''
      install -Dm444 ${contents}/usr/share/applications/com.discord.libdiscord.desktop \
        $out/share/applications/com.discord.libdiscord.desktop
      cp -r ${contents}/usr/share/icons $out/share/
    '';

    meta = {
      description = "Discord Phoenix (native libdiscord/GPUI desktop client leak, AppImage)";
      homepage = "https://discord.com";
      mainProgram = pname;
      platforms = ["x86_64-linux"];
    };
  }
