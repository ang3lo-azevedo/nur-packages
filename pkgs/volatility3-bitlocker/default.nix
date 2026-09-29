{
  lib,
  stdenvNoCC,
  callPackage,
}: let
  sources = callPackage ../../_sources/generated.nix {};
in
  stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "volatility3-bitlocker";
    inherit (sources.volatility3-bitlocker) version src;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      install -Dm644 bitlocker.py $out/share/volatility3/plugins/windows/bitlocker.py
      runHook postInstall
    '';

    # Pass to Volatility 3 as `-p`; the plugin is then windows.bitlocker.BitlockerFVEKScan
    passthru.pluginDir = "${finalAttrs.finalPackage}/share/volatility3/plugins";

    meta = with lib; {
      description = "Volatility 3 plugin for extracting BitLocker Full Volume Encryption Keys (FVEK)";
      homepage = "https://github.com/lorelyai/volatility3-bitlocker";
      license = licenses.gpl3Only;
      platforms = platforms.all;
    };
  })
