{
  lib,
  stdenvNoCC,
  makeWrapper,
  binutils,
  coreutils,
  findutils,
  gnugrep,
  runtimeShell,
  vol-rs,
  volatility3,
  volatility3-plugins,
  callPackage,
}: let
  sources = callPackage ../../_sources/generated.nix {};
  volatility3' = volatility3.overridePythonAttrs (old: {
    dependencies = old.dependencies ++ volatility3-plugins.pythonDependencies;
  });
in
  stdenvNoCC.mkDerivation {
    pname = "volatility-toolkit";
    version = sources.volatility-toolkit.version;
    dontBuild = true;

    src = sources.volatility-toolkit.src;

    nativeBuildInputs = [makeWrapper];

    # Runs windows.bitlocker.BitlockerFVEKScan and windows.pypykatz on every
    # Windows dump (--no-bitlocker and --no-credentials skip them), adds more
    # default Windows and Linux plugins, renames deprecated ones, and adds
    # --deep and --timeline (also to the shell completions). The BitLocker and
    # credential results also go into the --json report. KeePass is scanned when
    # it is running, and --timeline also writes a mactime bodyfile. Symbols are
    # fetched once before plugins run in parallel.
    patches = [
      ./bitlocker-scan.patch
      ./credentials-scan.patch
      ./extra-plugins.patch
      ./completions.patch
      ./json-report.patch
      ./timeline-keepass.patch
      ./symbol-fetch.patch
    ];

    # Fix bash set -e bug where (( i++ )) causes the script to abort when i=0.
    # Colors are defined as literal '\033' text, which only renders through
    # printf %b, so messages printed with %s show raw escapes; use $'' quoting.
    # The name comes from $0, which wrapProgram turns into .vol-analyze-wrapped.
    postPatch = ''
      sed -E -i 's/\(\([[:space:]]*[a-zA-Z0-9_]+\+\+[[:space:]]*\)\)/& || true/g' scripts/vol-analyze.sh
      sed -i "s/='\\\\033\[/=\$'\\\\033[/" scripts/vol-analyze.sh
      substituteInPlace scripts/vol-analyze.sh \
        --replace-fail 'SCRIPT_NAME="$(basename "$0")"' 'SCRIPT_NAME="vol-analyze"'
    '';

    installPhase = ''
      runHook preInstall

      install -Dm755 scripts/vol-analyze.sh $out/bin/vol-analyze
      install -Dm644 completions/vol-analyze.bash $out/share/bash-completion/completions/vol-analyze
      install -Dm644 completions/vol-analyze.zsh $out/share/zsh/site-functions/_vol-analyze
      install -d $out/share/doc/volatility-toolkit
      install -m644 docs/*.md -t $out/share/doc/volatility-toolkit

      HOME=$TMPDIR ${lib.getExe vol-rs} -h \
        | awk '/^    [^ ]/ && $1 ~ /^[a-z]+(\.[A-Za-z0-9_]+)+$/ { print $1 }' \
        > $out/share/volatility-toolkit-plugins
      [[ -s $out/share/volatility-toolkit-plugins ]]
      install -Dm755 ${./vol-shim.sh} $out/libexec/vol
      substituteInPlace $out/libexec/vol \
        --subst-var-by shell ${runtimeShell} \
        --subst-var-by plugins $out/share/volatility-toolkit-plugins \
        --subst-var-by vol ${lib.getExe vol-rs} \
        --subst-var-by vol3 ${lib.getExe' volatility3' "vol"} \
        --subst-var-by vol3PluginDirs ${volatility3-plugins.pluginDir}

      wrapProgram $out/bin/vol-analyze \
        --prefix PATH : ${lib.makeBinPath [
        binutils
        coreutils
        findutils
        gnugrep
        vol-rs
      ]} \
        --set VOL3_CMD $out/libexec/vol

      # Also the interactive `vol`: vol-rs speed, Volatility 3 when vol-rs fails
      ln -s $out/libexec/vol $out/bin/vol

      runHook postInstall
    '';

    meta = with lib; {
      description = "Automated memory forensics wrapper around Volatility 3";
      homepage = "https://github.com/gl0bal01/volatility-toolkit";
      license = licenses.agpl3Only;
      platforms = platforms.all;
      mainProgram = "vol-analyze";
    };
  }
