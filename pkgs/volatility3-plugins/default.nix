{
  lib,
  symlinkJoin,
  callPackage,
  python3Packages,
}: let
  plugins = [
    (callPackage ../volatility3-bitlocker {})
    (callPackage ../volatility3-fblock {})
    (callPackage ../volatility3-forensicxlab {})
    (callPackage ../volatility3-kevthehermit {})
    (callPackage ../volatility3-openssh-sessionkeys {})
    (callPackage ../volatility3-pypykatz {inherit python3Packages;})
  ];
  self = symlinkJoin {
    name = "volatility3-plugins";
    paths = plugins;

    passthru = {
      # Pass to Volatility 3 as `-p`
      pluginDir = "${self}/share/volatility3/plugins";
      # Must be importable by Volatility 3 itself, so override its dependencies with these
      pythonDependencies = lib.concatMap (p: p.pythonDependencies or []) plugins;
    };

    meta = {
      description = "Third-party Volatility 3 plugins, merged into one plugin directory";
      platforms = lib.platforms.all;
    };
  };
in
  self
