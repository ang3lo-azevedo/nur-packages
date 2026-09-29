{
  lib,
  stdenvNoCC,
  callPackage,
}: let
  sources = callPackage ../../_sources/generated.nix {};
in
  stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "volatility3-fblock";
    inherit (sources.volatility3-fblock) version src;
    dontBuild = true;

    # ptenum only needs old_div from the Python 2 compatibility library future,
    # and every call divides integers
    patches = [./drop-future.patch];

    installPhase = ''
      runHook preInstall
      install -Dm644 -t $out/share/volatility3/plugins/windows *.py
      runHook postInstall
    '';

    # Pass to Volatility 3 as `-p`
    passthru.pluginDir = "${finalAttrs.finalPackage}/share/volatility3/plugins";

    meta = with lib; {
      description = "Volatility 3 plugins for PTE-based malfind, patched image detection and API hook search";
      homepage = "https://github.com/f-block/volatility-plugins";
      license = with licenses; [mit gpl2Plus];
      platforms = platforms.all;
    };
  })
