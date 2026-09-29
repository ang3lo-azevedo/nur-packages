{
  lib,
  stdenvNoCC,
  callPackage,
}: let
  sources = callPackage ../../_sources/generated.nix {};
in
  stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "volatility3-kevthehermit";
    inherit (sources.volatility3-kevthehermit) version src;
    dontBuild = true;

    # Ports the plugins to the Volatility 3 2.x pslist and yarascan APIs
    patches = [./volatility-2.x.patch];

    installPhase = ''
      runHook preInstall
      install -Dm644 -t $out/share/volatility3/plugins/windows vol3/*/*.py
      runHook postInstall
    '';

    # Pass to Volatility 3 as `-p`
    passthru.pluginDir = "${finalAttrs.finalPackage}/share/volatility3/plugins";

    meta = with lib; {
      description = "Volatility 3 plugins for Cobalt Strike configs, password managers, Rich headers and Zone.Identifier streams";
      homepage = "https://github.com/kevthehermit/volatility_plugins";
      license = licenses.mit;
      platforms = platforms.all;
    };
  })
