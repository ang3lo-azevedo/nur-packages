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
  callPackage,
}: let
  sources = callPackage ../../_sources/generated.nix {};
in
  stdenvNoCC.mkDerivation {
    pname = "volatility-toolkit";
    version = sources.volatility-toolkit.version;
    dontBuild = true;

    src = sources.volatility-toolkit.src;

    nativeBuildInputs = [makeWrapper];

    # Fix bash set -e bug where (( i++ )) causes the script to abort when i=0.
    # Colors are defined as literal '\033' text, which only renders through
    # printf %b, so messages printed with %s show raw escapes; use $'' quoting.
    postPatch = ''
      sed -E -i 's/\(\([[:space:]]*[a-zA-Z0-9_]+\+\+[[:space:]]*\)\)/& || true/g' scripts/vol-analyze.sh
      sed -i "s/='\\\\033\[/=\$'\\\\033[/" scripts/vol-analyze.sh
    '';

    installPhase = ''
      runHook preInstall

      install -Dm755 scripts/vol-analyze.sh $out/bin/vol-analyze
      install -Dm644 completions/vol-analyze.bash $out/share/bash-completion/completions/vol-analyze
      install -Dm644 completions/vol-analyze.zsh $out/share/zsh/site-functions/_vol-analyze
      install -d $out/share/doc/volatility-toolkit
      install -m644 docs/*.md -t $out/share/doc/volatility-toolkit

      HOME=$TMPDIR ${vol-rs}/bin/vol -h \
        | awk '/^    [^ ]/ && $1 ~ /^[a-z]+(\.[A-Za-z0-9_]+)+$/ { print $1 }' \
        > $out/share/volatility-toolkit-plugins
      [[ -s $out/share/volatility-toolkit-plugins ]]
      install -Dm755 ${./vol-shim.sh} $out/libexec/vol
      substituteInPlace $out/libexec/vol \
        --subst-var-by shell ${runtimeShell} \
        --subst-var-by plugins $out/share/volatility-toolkit-plugins \
        --subst-var-by vol ${vol-rs}/bin/vol \
        --subst-var-by vol3 ${lib.getExe' volatility3 "vol"}

      wrapProgram $out/bin/vol-analyze \
        --prefix PATH : ${lib.makeBinPath [
        binutils
        coreutils
        findutils
        gnugrep
        vol-rs
      ]} \
        --set VOL3_CMD $out/libexec/vol

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
