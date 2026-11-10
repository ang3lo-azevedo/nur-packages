{
  stdenvNoCC,
  fetchurl,
  makeWrapper,
  cacert,
}:
# oceanpacificpeace/lichii-shader-sync: downloads shared Vulkan shader caches into
# Lichii/Eden so games stutter less on first play (an automated alternative to
# grabbing shader packs by hand). Upstream ships a statically linked Go binary per
# platform; we install the linux-amd64 one as `lichii-sync`. App releases are
# tagged vX.Y.Z (the only ones marked "latest"; shader packs are separate,
# non-latest releases), so the URL templates off `version`. Run ./update.sh to
# refresh `version` and `hash`.
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "lichii-shader-sync";
  version = "1.2.0";

  src = fetchurl {
    url = "https://github.com/oceanpacificpeace/lichii-shader-sync/releases/download/v${finalAttrs.version}/lichii-sync-linux-amd64";
    hash = "sha256-AVglUebfHFA+9d7Eg6J6w/l1fpCtxXEFkO9Dk9PC/vw=";
  };

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
})
