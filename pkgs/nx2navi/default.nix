{
  lib,
  buildFHSEnv,
  writeShellScript,
  vulkan-memory-allocator,
  callPackage,
}: let
  sources = callPackage ../../_sources/generated.nix {};
  inherit (sources.nx2navi) version src;

  # VMA ships one header; pointing make_game.py at it (VMA_INCLUDE) stops the build
  # from downloading and hash-checking its own copy into the kit's toolchain/vma.
  vmaInclude = "${vulkan-memory-allocator}/include";

  # NX2navi has no distributable artifact: it recompiles Ocarina of Time from the
  # player's own dump on this machine (20 to 45 minutes). The build and the shader
  # translator write into the source tree and create uv-managed Python venvs that
  # install native manylinux wheels (lief, unicorn, oead, quicktex), which only run
  # under an FHS layout. So the package is an environment, not a built game: it
  # carries the whole toolchain and runs upstream's Linux build flow against a .nup
  # (packed from a dump with the `nup` tool) or an exefs/romfs pair.
  launcher = writeShellScript "nx2navi" ''
    set -euo pipefail

    kit_src=${src}
    kit_ver=${lib.escapeShellArg version}
    workdir="''${NX2NAVI_HOME:-''${XDG_DATA_HOME:-$HOME/.local/share}/nx2navi}"
    kit="$workdir/kit"
    stamp="$kit/.nx2navi-kit-version"

    # The kit must be writable (build_xlate.py patches a vendored tree, the compile
    # writes build-cache and objects), so work from a copy in $HOME, not the store.
    # Refresh it on a version bump while leaving the user's .venv, build/ and
    # toolchain/ in place; the source tree carries no .git, so patches apply as they
    # would outside a repository (build_xlate.py relies on that).
    if [ ! -f "$stamp" ] || [ "$(cat "$stamp" 2>/dev/null)" != "$kit_ver" ]; then
      echo "nx2navi: installing build kit $kit_ver into $kit"
      mkdir -p "$kit"
      cp -a --no-preserve=mode,ownership "$kit_src"/. "$kit"/
      chmod -R u+w "$kit"
      printf '%s' "$kit_ver" > "$stamp"
    fi

    cd "$kit"
    export VMA_INCLUDE=${lib.escapeShellArg vmaInclude}

    # One uv venv (python 3.12) covers both build_xlate.py and make_game.py. zbic is
    # not in requirements.txt but make_game.py's exefs step needs it (pip install zbic).
    if [ ! -x "$kit/.venv/bin/python" ]; then
      echo "nx2navi: creating .venv (uv, python 3.12) and installing build requirements"
      uv venv --python 3.12 .venv
      uv pip install --python .venv/bin/python -r tools/requirements.txt zbic
    fi
    py="$kit/.venv/bin/python"

    # NativeAOT shader translator, built once (dotnet publish + clang/lld). make_game.py
    # refuses to run without build/xlate/nx2navi_xlate.
    if [ ! -x "$kit/build/xlate/nx2navi_xlate" ]; then
      echo "nx2navi: building shader translator (dotnet publish, NativeAOT)"
      "$py" -I tools/build_xlate.py
    fi

    if [ "$#" -eq 0 ]; then
      cat <<EOF
    nx2navi build kit ready in $kit
    Toolchain (clang, lld, dotnet, uv, vulkan, sdl3) is on PATH; VMA_INCLUDE is set.

    Build the game from a .nup packed with the nup tool:
      nx2navi --nup /path/to/game.nup --out ~/Games/ocarina
    then run it from inside this environment (it links the sandbox's libraries):
      nx2navi    # drops you here, then: ~/Games/ocarina/ocarina

    Other build steps live in docs/building.md; run them as: $py -I tools/<script>.py ...
    EOF
      exec "''${SHELL:-bash}"
    fi

    exec "$py" -I tools/make_game.py "$@"
  '';
in
  buildFHSEnv {
    name = "nx2navi";
    inherit version;
    runScript = "${launcher}";

    targetPkgs = pkgs:
      with pkgs; [
        # Build toolchain: clang/lld compile the lifted C and link the game and the
        # NativeAOT translator; dotnet builds the translator; uv manages the venv.
        clang
        lld
        llvm
        dotnet-sdk_10
        uv
        git
        gnumake
        ninja
        pkg-config
        python312
        # Shader tooling named by docs/building.md.
        shaderc
        spirv-tools
        # Libraries the game links (libstdc++ is linked static, the rest are system
        # libraries with rpath $ORIGIN) and the shaders need at runtime.
        sdl3
        libopus
        libvpx
        dav1d
        zstd
        vulkan-loader
        vulkan-headers
        vulkan-validation-layers
        vulkan-memory-allocator
        # Common runtime deps for dotnet and the native Python wheels.
        stdenv.cc.cc.lib
        zlib
        openssl
        icu
        libunwind
        # Shell utilities the build scripts shell out to.
        coreutils
        bash
        which
        gnused
        gnugrep
        gawk
        findutils
      ];

    meta = with lib; {
      description = "Static recompilation of The Legend of Zelda: Ocarina of Time for Switch 2 (build toolkit)";
      longDescription = ''
        NX2navi recompiles Ocarina of Time (Switch 2, game 1.1.1) into a native
        Vulkan executable from the player's own legally dumped game files. No game
        content ships with it. This package provides the Linux build environment:
        it copies the kit into ~/.local/share/nx2navi, builds the shader translator,
        and runs tools/make_game.py against a .nup (packed with the nup tool) or an
        exefs/romfs pair to produce the ocarina binary.
      '';
      homepage = "https://github.com/tangerineturtle1/NX2navi";
      # MIT base import plus an all-rights-reserved LICENSE-ADDITIONS: treat as unfree.
      license = licenses.unfree;
      maintainers = [];
      mainProgram = "nx2navi";
      platforms = ["x86_64-linux"];
    };
  }
