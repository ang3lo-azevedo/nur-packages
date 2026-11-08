# Force appimageTools AppImage extraction to build locally.
#
# Every appimageTools.extract / wrapType2 package in this NUR (the nx2 emulators,
# jackify, hookshot, and the rest) pulls a large AppImage from a custom GitHub or
# GitLab URL that cache.nixos.org never holds, then does nothing but untar it.
# When this NUR is consumed with distributed builds on (the parent's
# modules/system/nixbuild), Nix routes that untar to the remote builder, which
# first has to upload the whole AppImage (the emulators are ~130 MiB each, jackify
# and hookshot north of 200 MiB): minutes of upstream bandwidth per version bump
# for a step worth seconds locally.
#
# The untar is a runCommand named "<pname>-<version>-extracted". Both the public
# appimageTools.extract and the copy wrapType2 runs internally go through the
# module's own runCommand argument, so override that one argument to stamp
# preferLocalBuild on the extraction (overriding the .extract attribute alone
# would miss the wrapType2 path, which closes over the module-local binding). This
# shifts the extracted output hash, which costs nothing: these are consumed only
# on the one desktop and were never in a shared cache anyway.
#
# Kept in sync with the parent repo's overlays/appimage-local-build.nix, which
# does the same for appimageTools packages that come straight from nixpkgs. Both
# are needed because the parent and this NUR evaluate separate nixpkgs instances.
final: prev: {
  appimageTools = prev.appimageTools.override {
    runCommand = name: env: cmd: prev.runCommand name (env // {preferLocalBuild = true;}) cmd;
  };
}
