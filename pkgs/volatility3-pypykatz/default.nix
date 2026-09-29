{
  lib,
  stdenvNoCC,
  callPackage,
  python3Packages,
}: let
  sources = callPackage ../../_sources/generated.nix {};
in
  stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "volatility3-pypykatz";
    inherit (sources.volatility3-pypykatz) version src;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      install -Dm644 vol_pypykatz.py $out/share/volatility3/plugins/windows/pypykatz.py
      runHook postInstall
    '';

    passthru = {
      # Pass to Volatility 3 as `-p`; the plugin is then windows.pypykatz.pypykatz
      pluginDir = "${finalAttrs.finalPackage}/share/volatility3/plugins";
      # The plugin only wraps the pypykatz library, which must be importable by Volatility 3 itself
      pythonDependencies = [python3Packages.pypykatz];
    };

    meta = with lib; {
      description = "Volatility 3 plugin for extracting Windows credentials from LSASS with pypykatz";
      homepage = "https://github.com/skelsec/pypykatz-volatility3";
      license = licenses.mit;
      platforms = platforms.all;
    };
  })
