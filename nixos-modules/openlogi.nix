{
  lib,
  pkgs,
  ...
}: let
  # Read straight from the nvfetcher output: imports cannot depend on pkgs
  source = (lib.importJSON ../_sources/generated.json).openlogi.src;
  src = builtins.fetchTarball {inherit (source) url sha256;};
in {
  # Upstream's own module: package, udev rules and the agent's user service
  imports = ["${src}/packaging/linux/nixos-module.nix"];

  programs.openlogi.package = lib.mkDefault (pkgs.callPackage ../pkgs/openlogi {});
}
