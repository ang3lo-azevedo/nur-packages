{pkgs, ...}: let
  sources = pkgs.callPackage ../../_sources/generated.nix {};

  # Upstream's package.nix filters the source with lib.fileset, which only accepts
  # a path, not the store path string that fetchTarball returns
  src = /. + builtins.unsafeDiscardStringContext sources.openlogi.src;
in
  # The build recipe is upstream's own, taken from the release nvfetcher tracks
  pkgs.callPackage (src + "/packaging/linux/package.nix") {inherit src;}
