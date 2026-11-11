# Keep appimageTools AppImage extraction off the eu.nixbuild.net remote builder.
#
# appimageTools packages fetch a large AppImage, then do nothing but unsquashfs it.
# With distributed builds on (modules/system/nixbuild), Nix can route that extraction
# to the remote builder, which first has to upload the whole AppImage: minutes of
# upstream bandwidth for a step worth seconds locally, and the unfree ones are never
# in cache.nixos.org to pull from instead.
#
# Tagging with requiredSystemFeatures = ["nixos-test"] (advertised only by the local
# host in nix.settings.system-features, not by eu.nixbuild.net) keeps the extraction
# on this machine. Substitution stays enabled, so a build already cached on nixbuild
# is still pulled rather than re-extracted.
#
# NOTE: this deliberately does NOT touch buildFHSEnv/buildFHSEnvBubblewrap. Those
# rootfs derivations are non-deterministic (the symlink farm and glib schema
# compilation differ between hosts); forcing them to build locally instead of being
# substituted from nixbuild produces a broken rootfs where the dynamic linker cannot
# resolve libraries that are physically present (observed with hookshot: SDL2 failing
# to find libwayland, and with nixpkgs zoom-us: ZoomLauncher failing on libglib).
# FHS packages, including appimageTools.wrapType2, must come from nixbuild or cache.
_: prev: {
  appimageTools = prev.appimageTools.override {
    runCommand = name: env: cmd:
      prev.runCommand name (
        env
        // {
          preferLocalBuild = true;
          requiredSystemFeatures = (env.requiredSystemFeatures or []) ++ ["nixos-test"];
        }
      )
      cmd;
  };
}
