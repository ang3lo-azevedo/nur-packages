{
  eden,
  callPackage,
  fetchFromGitHub,
}: let
  sources = callPackage ../../_sources/generated.nix {};

  # Switch 2 adds zbic texture (de)compression, a header-only CPM dependency Eden
  # never pulled. eden builds with CPMUTIL_FORCE_SYSTEM, so CPMUtil does
  # find_package(zbic) and aborts since it is not in nixpkgs. Pre-fetch the pinned
  # source (rev/hash from Eglantine's cpmfile.json) and hand it to CPMUtil below.
  zbicSrc = fetchFromGitHub {
    owner = "kinnay";
    repo = "zbic";
    rev = "11b08f2712264bbed731545085cbd9702096ceb7";
    hash = "sha256-pHvxa1gkUvQo6mUgmLWtj1kcu01BLdGmttZyb8ZAj/o=";
  };
in
  # Eglantine is a Switch 2 emulator derived from Eden, so reuse nixpkgs' eden
  # derivation (Qt, Vulkan, SDL, system-library deps via CPMUTIL_FORCE_SYSTEM) and
  # swap in Eglantine's nx2 source (tracked by nvfetcher) instead of repackaging.
  eden.overrideAttrs (old: {
    pname = "eglantine";
    version = "nx2-unstable-${sources.eglantine.date}";
    src = sources.eglantine.src;

    # zbic_FORCE_BUNDLED overrides the global CPMUTIL_FORCE_SYSTEM so CPMUtil skips
    # find_package for zbic, and zbic_CUSTOM_DIR points it at the pre-fetched source
    # so it never tries to download (the Nix build sandbox has no network).
    cmakeFlags =
      (old.cmakeFlags or [])
      ++ [
        "-Dzbic_FORCE_BUNDLED=ON"
        "-Dzbic_CUSTOM_DIR=${zbicSrc}"
      ];

    # Eglantine renamed the udev rules file (yuzu -> eden) and the GUI binary
    # (yuzu -> eglantine, via OUTPUT_NAME in src/yuzu/CMakeLists.txt), so eden's own
    # postInstall/mainProgram no longer match.
    postInstall = ''
      install -Dm444 $src/dist/72-eden-input.rules $out/lib/udev/rules.d/72-eden-input.rules
    '';

    # eden sets LD_LIBRARY_PATH through qtWrapperArgs in preFixup; append the eGPU
    # offload so the Qt wrapper runs the emulator on the AMD eGPU (Navi 44, RX 9060 XT,
    # 1002:7590) for Vulkan, with DRI_PRIME for any GL path. --set-default so an
    # unplugged eGPU falls back to the iGPU and a manual env still wins.
    preFixup =
      (old.preFixup or "")
      + ''
        qtWrapperArgs+=(--set-default MESA_VK_DEVICE_SELECT 1002:7590)
        qtWrapperArgs+=(--set-default DRI_PRIME 1)
      '';

    meta =
      old.meta
      // {
        description = "Experimental Nintendo Switch 2 emulator derived from Eden, Yuzu and Sudachi";
        mainProgram = "eglantine";
      };
  })
