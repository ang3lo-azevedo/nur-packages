{ pkgs ? import <nixpkgs> { } }:

{
  lib = import ./lib { inherit pkgs; };
  nixosModules = import ./nixos-modules;
  overlays = import ./overlays;

  analyzeMFT = pkgs.callPackage ./pkgs/analyzeMFT {};
  apk-mitm = pkgs.callPackage ./pkgs/apk-mitm {};
  archi = pkgs.callPackage ./pkgs/archi {};
  betterbird = pkgs.callPackage ./pkgs/betterbird {};
  chainsaw-rules = pkgs.callPackage ./pkgs/chainsaw-rules {};
  ciphey = pkgs.callPackage ./pkgs/ciphey {};
  ctfd-parser = pkgs.callPackage ./pkgs/ctfd-parser {};
  cursor-id-modifier = pkgs.callPackage ./pkgs/cursor-id-modifier {};
  dnspy = pkgs.callPackage ./pkgs/dnspy {};
  ese-database-view = pkgs.callPackage ./pkgs/ese-database-view {};
  evolve = pkgs.callPackage ./pkgs/evolve {};
  ffmpeg-encoder-plugin-resolve = pkgs.callPackage ./pkgs/ffmpeg-encoder-plugin-resolve {};
  harbor = pkgs.callPackage ./pkgs/harbor {};
  hayabusa = pkgs.callPackage ./pkgs/hayabusa {};
  jackify = pkgs.callPackage ./pkgs/jackify {};
  libesedb = pkgs.callPackage ./pkgs/libesedb {};
  libfsntfs = pkgs.callPackage ./pkgs/libfsntfs {};
  linoffice = pkgs.callPackage ./pkgs/linoffice {};
  monkeylauncher = pkgs.callPackage ./pkgs/monkeylauncher {};
  nordvpn = pkgs.callPackage ./pkgs/nordvpn {};
  nuvio = pkgs.callPackage ./pkgs/nuvio {};
  onlinefix-linux = pkgs.callPackage ./pkgs/onlinefix-linux {};
  proton-linuwux = pkgs.callPackage ./pkgs/proton-linuwux {};
  registry-spy = pkgs.callPackage ./pkgs/registry-spy {};
  rem = pkgs.callPackage ./pkgs/rem {};
  rsactftool = pkgs.callPackage ./pkgs/rsactftool {};
  scrollmpris = pkgs.callPackage ./pkgs/scrollmpris {};
  sidr = pkgs.callPackage ./pkgs/sidr {};
  so-crates = pkgs.callPackage ./pkgs/so-crates {};
  sstv = pkgs.callPackage ./pkgs/sstv {};
  steamidra = pkgs.callPackage ./pkgs/steamidra {};
  stremio-enhanced = pkgs.callPackage ./pkgs/stremio-enhanced {};
  sysmontools = pkgs.callPackage ./pkgs/sysmontools {};
  tplmap = pkgs.callPackage ./pkgs/tplmap {};
  trakt-scrobbler = pkgs.callPackage ./pkgs/trakt-scrobbler {};
  volatility-toolkit = pkgs.callPackage ./pkgs/volatility-toolkit {};
}
