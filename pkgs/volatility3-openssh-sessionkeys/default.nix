{
  lib,
  stdenvNoCC,
  callPackage,
}: let
  sources = callPackage ../../_sources/generated.nix {};
in
  stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "volatility3-openssh-sessionkeys";
    inherit (sources.volatility3-openssh-sessionkeys) version src;
    dontBuild = true;

    # Raises the pslist requirement to the Volatility 3 2.x Linux API
    patches = [./volatility-2.x.patch];

    installPhase = ''
      runHook preInstall
      install -Dm644 -t $out/share/volatility3/plugins/linux volatility3/openssh_sessionkeys.py
      runHook postInstall
    '';

    # Pass to Volatility 3 as `-p`
    passthru.pluginDir = "${finalAttrs.finalPackage}/share/volatility3/plugins";

    meta = with lib; {
      description = "Volatility 3 plugin that recovers OpenSSH session keys from Linux memory";
      homepage = "https://github.com/fox-it/OpenSSH-Session-Key-Recovery";
      license = licenses.asl20;
      platforms = platforms.all;
    };
  })
