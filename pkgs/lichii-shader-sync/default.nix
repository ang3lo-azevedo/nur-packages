{
  stdenvNoCC,
  callPackage,
  makeWrapper,
  cacert,
}: let
  sources = callPackage ../../_sources/generated.nix {};
in
  # oceanpacificpeace/lichii-shader-sync: downloads shared Vulkan shader caches into
  # Lichii/Eden so games stutter less on first play (an automated alternative to
  # grabbing shader packs by hand). Upstream ships a statically linked Go binary per
  # platform; we install the linux-amd64 one as `lichii-sync`. App releases are
  # tracked automatically via nvfetcher in nvfetcher.toml.
  stdenvNoCC.mkDerivation {
    pname = "lichii-shader-sync";
    version = sources.lichii-shader-sync.version;
    src = sources.lichii-shader-sync.src;

    dontUnpack = true;
    nativeBuildInputs = [makeWrapper];

    installPhase = ''
      runHook preInstall
      install -Dm755 $src $out/bin/lichii-sync
      # It fetches packs over HTTPS; point Go at a CA bundle, but let a system
      # SSL_CERT_FILE still win.
      wrapProgram $out/bin/lichii-sync \
        --set-default SSL_CERT_FILE ${cacert}/etc/ssl/certs/ca-bundle.crt
      runHook postInstall
    '';

    meta = {
      description = "Downloads shared Vulkan shader caches into Lichii/Eden to reduce first-play stutter";
      homepage = "https://github.com/oceanpacificpeace/lichii-shader-sync";
      mainProgram = "lichii-sync";
      platforms = ["x86_64-linux"];
    };
  }
