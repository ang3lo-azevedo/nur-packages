{
  eden,
  callPackage,
}: let
  sources = callPackage ../../_sources/generated.nix {};
in
  # Eglantine is a Switch 2 emulator derived from Eden, so reuse nixpkgs' eden
  # derivation (Qt, Vulkan, SDL, system-library deps via CPMUTIL_FORCE_SYSTEM) and
  # swap in Eglantine's nx2 source (tracked by nvfetcher) instead of repackaging.
  eden.overrideAttrs (old: {
    pname = "eglantine";
    version = "nx2-unstable-${sources.eglantine.date}";
    src = sources.eglantine.src;

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
