{
  lib,
  stdenvNoCC,
  callPackage,
}: let
  sources = callPackage ../../_sources/generated.nix {};
in
  stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "volatility3-forensicxlab";
    inherit (sources.volatility3-forensicxlab) version src;
    dontBuild = true;

    # Ports the plugins to the Volatility 3 2.x pslist and filescan APIs
    patches = [./volatility-2.x.patch];

    installPhase = ''
      runHook preInstall
      install -Dm644 -t $out/share/volatility3/plugins/windows anydesk.py keepass.py prefetch.py
      install -Dm644 -t $out/share/volatility3/plugins/linux inodes.py
      runHook postInstall
    '';

    # Pass to Volatility 3 as `-p`
    passthru.pluginDir = "${finalAttrs.finalPackage}/share/volatility3/plugins";

    meta = with lib; {
      description = "Volatility 3 plugins for KeePass, Prefetch, AnyDesk and Linux inode artifacts";
      homepage = "https://github.com/forensicxlab/volatility3_plugins";
      # No license in the repository
      license = licenses.unfree;
      platforms = platforms.all;
    };
  })
