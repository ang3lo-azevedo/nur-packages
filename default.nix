{ pkgs ? import <nixpkgs> { } }:

{
  lib = import ./lib { inherit pkgs; };
  nixosModules = import ./nixos-modules;
  overlays = import ./overlays;

  aleapp = pkgs.callPackage ./pkgs/aleapp {
    bencoding = pkgs.callPackage ./pkgs/bencoding {};
    pyliblzfse = pkgs.callPackage ./pkgs/pyliblzfse {};
    mister-skinnylegs = pkgs.callPackage ./pkgs/mister-skinnylegs {
      ccl-chromium-reader = pkgs.callPackage ./pkgs/ccl-chromium-reader {
        ccl-simplesnappy = pkgs.callPackage ./pkgs/ccl-simplesnappy {};
      };
      ccl-mozilla-reader = pkgs.callPackage ./pkgs/ccl-mozilla-reader {
        ccl-simplesnappy = pkgs.callPackage ./pkgs/ccl-simplesnappy {};
      };
    };
  };
  analyzeMFT = pkgs.callPackage ./pkgs/analyzeMFT {};
  apachelogs = pkgs.callPackage ./pkgs/apachelogs {
    pydicti = pkgs.callPackage ./pkgs/pydicti {};
  };
  apk-mitm = pkgs.callPackage ./pkgs/apk-mitm {};
  archi = pkgs.callPackage ./pkgs/archi {};
  astc-decomp-faster = pkgs.callPackage ./pkgs/astc-decomp-faster {};
  bloodhound-quickwin = pkgs.callPackage ./pkgs/bloodhound-quickwin {
    py2neo = pkgs.callPackage ./pkgs/py2neo {
      interchange = pkgs.callPackage ./pkgs/interchange {};
      pansi = pkgs.callPackage ./pkgs/pansi {};
    };
  };
  batch-leapp = pkgs.callPackage ./pkgs/batch-leapp {};
  bencoding = pkgs.callPackage ./pkgs/bencoding {};
  betterbird = pkgs.callPackage ./pkgs/betterbird {};
  ccl-chromium-reader = pkgs.callPackage ./pkgs/ccl-chromium-reader {
    ccl-simplesnappy = pkgs.callPackage ./pkgs/ccl-simplesnappy {};
  };
  ccl-mozilla-reader = pkgs.callPackage ./pkgs/ccl-mozilla-reader {
    ccl-simplesnappy = pkgs.callPackage ./pkgs/ccl-simplesnappy {};
  };
  ccl-simplesnappy = pkgs.callPackage ./pkgs/ccl-simplesnappy {};
  chainsaw-rules = pkgs.callPackage ./pkgs/chainsaw-rules {};
  cleapp = pkgs.callPackage ./pkgs/cleapp {
    freesimplegui = pkgs.callPackage ./pkgs/freesimplegui {};
  };
  interchange = pkgs.callPackage ./pkgs/interchange {};
  ciphey = pkgs.callPackage ./pkgs/ciphey {};
  ctf-dl = pkgs.callPackage ./pkgs/ctf-dl {
    ctfbridge = pkgs.callPackage ./pkgs/ctfbridge {};
  };
  ctfbridge = pkgs.callPackage ./pkgs/ctfbridge {};
  ctfd-parser = pkgs.callPackage ./pkgs/ctfd-parser {};
  cursor-id-modifier = pkgs.callPackage ./pkgs/cursor-id-modifier {};
  dleapp = pkgs.callPackage ./pkgs/dleapp {
    bencoding = pkgs.callPackage ./pkgs/bencoding {};
    pyliblzfse = pkgs.callPackage ./pkgs/pyliblzfse {};
    python-evtx = pkgs.callPackage ./pkgs/python-evtx {};
    unifiedlog-iterator = pkgs.callPackage ./pkgs/unifiedlog-iterator {};
  };
  dnspy = pkgs.callPackage ./pkgs/dnspy {};
  ese-database-view = pkgs.callPackage ./pkgs/ese-database-view {};
  evolve = pkgs.callPackage ./pkgs/evolve {};
  ffmpeg-encoder-plugin-resolve = pkgs.callPackage ./pkgs/ffmpeg-encoder-plugin-resolve {};
  freesimplegui = pkgs.callPackage ./pkgs/freesimplegui {};
  gdsdecomp = pkgs.callPackage ./pkgs/gdsdecomp {};
  gleapp = pkgs.callPackage ./pkgs/gleapp {
    pyliblzfse = pkgs.callPackage ./pkgs/pyliblzfse {};
    texture2ddecoder = pkgs.callPackage ./pkgs/texture2ddecoder {};
  };
  harbor = pkgs.callPackage ./pkgs/harbor {};
  hayabusa = pkgs.callPackage ./pkgs/hayabusa {};
  hindsight = pkgs.callPackage ./pkgs/hindsight {
    ccl-chromium-reader = pkgs.callPackage ./pkgs/ccl-chromium-reader {
      ccl-simplesnappy = pkgs.callPackage ./pkgs/ccl-simplesnappy {};
    };
  };
  hyprfm = pkgs.callPackage ./pkgs/hyprfm {};
  ileapp = pkgs.callPackage ./pkgs/ileapp {
    astc-decomp-faster = pkgs.callPackage ./pkgs/astc-decomp-faster {};
    bencoding = pkgs.callPackage ./pkgs/bencoding {};
    mdplistlib = pkgs.callPackage ./pkgs/mdplistlib {};
    nska-deserialize = pkgs.callPackage ./pkgs/nska-deserialize {};
    pyliblzfse = pkgs.callPackage ./pkgs/pyliblzfse {};
    pytypedstream = pkgs.callPackage ./pkgs/pytypedstream {};
    unifiedlog-iterator = pkgs.callPackage ./pkgs/unifiedlog-iterator {};
  };
  jackify = pkgs.callPackage ./pkgs/jackify {};
  lava = pkgs.callPackage ./pkgs/lava {};
  libesedb = pkgs.callPackage ./pkgs/libesedb {};
  libfsntfs = pkgs.callPackage ./pkgs/libfsntfs {};
  libscca = pkgs.callPackage ./pkgs/libscca {};
  lleapp = pkgs.callPackage ./pkgs/lleapp {
    apachelogs = pkgs.callPackage ./pkgs/apachelogs {
      pydicti = pkgs.callPackage ./pkgs/pydicti {};
    };
    freesimplegui = pkgs.callPackage ./pkgs/freesimplegui {};
    utmp = pkgs.callPackage ./pkgs/utmp {};
  };
  linoffice = pkgs.callPackage ./pkgs/linoffice {};
  mdplistlib = pkgs.callPackage ./pkgs/mdplistlib {};
  mister-skinnylegs = pkgs.callPackage ./pkgs/mister-skinnylegs {
    ccl-chromium-reader = pkgs.callPackage ./pkgs/ccl-chromium-reader {
      ccl-simplesnappy = pkgs.callPackage ./pkgs/ccl-simplesnappy {};
    };
    ccl-mozilla-reader = pkgs.callPackage ./pkgs/ccl-mozilla-reader {
      ccl-simplesnappy = pkgs.callPackage ./pkgs/ccl-simplesnappy {};
    };
  };
  monkeylauncher = pkgs.callPackage ./pkgs/monkeylauncher {};
  nordvpn = pkgs.callPackage ./pkgs/nordvpn {};
  nuvio = pkgs.callPackage ./pkgs/nuvio {};
  nska-deserialize = pkgs.callPackage ./pkgs/nska-deserialize {};
  onlinefix-linux = pkgs.callPackage ./pkgs/onlinefix-linux {};
  openlogi = pkgs.callPackage ./pkgs/openlogi {};
  proton-linuwux = pkgs.callPackage ./pkgs/proton-linuwux {};
  pydicti = pkgs.callPackage ./pkgs/pydicti {};
  pyliblzfse = pkgs.callPackage ./pkgs/pyliblzfse {};
  python-evtx = pkgs.callPackage ./pkgs/python-evtx {};
  pytypedstream = pkgs.callPackage ./pkgs/pytypedstream {};
  pansi = pkgs.callPackage ./pkgs/pansi {};
  py2neo = pkgs.callPackage ./pkgs/py2neo {
    interchange = pkgs.callPackage ./pkgs/interchange {};
    pansi = pkgs.callPackage ./pkgs/pansi {};
  };
  registry-spy = pkgs.callPackage ./pkgs/registry-spy {};
  rem = pkgs.callPackage ./pkgs/rem {};
  rleapp = pkgs.callPackage ./pkgs/rleapp {
    bencoding = pkgs.callPackage ./pkgs/bencoding {};
    pyliblzfse = pkgs.callPackage ./pkgs/pyliblzfse {};
  };
  rsactftool = pkgs.callPackage ./pkgs/rsactftool {};
  scrollmpris = pkgs.callPackage ./pkgs/scrollmpris {};
  sidr = pkgs.callPackage ./pkgs/sidr {};
  so-crates = pkgs.callPackage ./pkgs/so-crates {};
  sstv = pkgs.callPackage ./pkgs/sstv {};
  steamidra = pkgs.callPackage ./pkgs/steamidra {};
  stremio-enhanced = pkgs.callPackage ./pkgs/stremio-enhanced {};
  sysmontools = pkgs.callPackage ./pkgs/sysmontools {};
  texture2ddecoder = pkgs.callPackage ./pkgs/texture2ddecoder {};
  tplmap = pkgs.callPackage ./pkgs/tplmap {};
  trakt-scrobbler = pkgs.callPackage ./pkgs/trakt-scrobbler {};
  unifiedlog-iterator = pkgs.callPackage ./pkgs/unifiedlog-iterator {};
  utmp = pkgs.callPackage ./pkgs/utmp {};
  vleapp = pkgs.callPackage ./pkgs/vleapp {
    pyliblzfse = pkgs.callPackage ./pkgs/pyliblzfse {};
  };
  volatility-toolkit = pkgs.callPackage ./pkgs/volatility-toolkit {
    vol-rs = pkgs.callPackage ./pkgs/vol-rs {};
    volatility3-plugins = pkgs.callPackage ./pkgs/volatility3-plugins {};
  };
  volatility3-bitlocker = pkgs.callPackage ./pkgs/volatility3-bitlocker {};
  volatility3-fblock = pkgs.callPackage ./pkgs/volatility3-fblock {};
  volatility3-forensicxlab = pkgs.callPackage ./pkgs/volatility3-forensicxlab {};
  volatility3-kevthehermit = pkgs.callPackage ./pkgs/volatility3-kevthehermit {};
  volatility3-openssh-sessionkeys = pkgs.callPackage ./pkgs/volatility3-openssh-sessionkeys {};
  volatility3-plugins = pkgs.callPackage ./pkgs/volatility3-plugins {};
  volatility3-pypykatz = pkgs.callPackage ./pkgs/volatility3-pypykatz {};
  vol-rs = pkgs.callPackage ./pkgs/vol-rs {};
  vorion = pkgs.callPackage ./pkgs/vorion {};
  zapfast = pkgs.callPackage ./pkgs/zapfast {};
angr-management = pkgs.callPackage ./pkgs/angr-management {};
  autodesk-fusion = pkgs.callPackage ./pkgs/autodesk-fusion {
    wine = pkgs.wineWow64Packages.full;
  };
  ist-fenix-auto-enroller = pkgs.callPackage ./pkgs/ist-fenix-auto-enroller {};
  tpm-keyring-unlock = pkgs.callPackage ./pkgs/tpm-keyring-unlock {};
}
