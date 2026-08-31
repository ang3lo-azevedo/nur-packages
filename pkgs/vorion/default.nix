{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchurl,
  rustPlatform,
  cmake,
  ninja,
  wrapGAppsHook4,
  glib-networking,
  gst_all_1,
  libsysprof-capture,
  libayatana-appindicator,
  nodejs,
  openssl,
  pkg-config,
  yq-go,
  pnpm_10,
  fetchPnpmDeps,
  pnpmConfigHook,
  webkitgtk_4_1,
  cargo-tauri,
  desktop-file-utils,
  pipewire,
  libnice,
}:

let
  webkitgtk_4_1' = webkitgtk_4_1.override {
    enableExperimental = true;
  };
  shelterJs = fetchurl {
    url = "https://raw.githubusercontent.com/uwu/shelter-builds/main/shelter.js";
    sha256 = "0zk89ww41qd5binrbpdx9203aw10x6i36v9i6yd9rd0k28m59bl6";
  };
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "vorion";
  version = "13bf254a806f9e062e5a09e00181917288bdf7b3";

  src = fetchFromGitHub {
    owner = "Zexolver";
    repo = "Vorion";
    rev = finalAttrs.version;
    hash = "sha256-TgU+qnbajJKZaVN27RXRxyqnEox4rpXcEmkldzr/ecg=";
  };

  cargoRoot = "src-tauri";
  buildAndTestSubdir = finalAttrs.cargoRoot;

  cargoHash = "sha256-mJ138nuqmUq/rI3nSsPVAcTL5E0vm8fIvw6G6EAzLWI=";

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm_10;
    fetcherVersion = 3;
    hash = "sha256-ZbRNZZoEa4lpn4QJ9DrZiWICLdyWVRDCqlEceFjMiWE=";
  };

  # CMake (webkit extension, Linux only)
  cmakeDir = ".";
  cmakeBuildDir = "src-tauri/extension_webkit";
  dontUseCmakeConfigure = true;
  dontUseNinjaBuild = true;
  dontUseNinjaCheck = true;
  dontUseNinjaInstall = true;
  cmakeFlags = [
    "-GNinja"
  ];

  nativeBuildInputs = [
    pnpmConfigHook
    pnpm_10
    cargo-tauri.hook
    nodejs
    pkg-config
    yq-go
    wrapGAppsHook4
    desktop-file-utils
    cmake
    ninja
  ];

  buildInputs = [
    openssl
    webkitgtk_4_1'
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-rs
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-libav
    libnice
    glib-networking
    libsysprof-capture
    libayatana-appindicator
    pipewire
  ];

  postPatch = ''
    # copy shelter.js
    cp ${shelterJs} src-tauri/injection/shelter.js

    # remove updater
    rm -rf updater || true

    # disable auto-updater from UI by removing the Shelter plugin
    sed -i '/Dorion Updater/d' src-tauri/injection/preinject.ts || true

    # disable pre-build script and disable auto-updater
    yq -iPo=json '
      .bundle.resources = (.bundle.resources | map(select(. != "updater*")))
    ' src-tauri/tauri.conf.json || true

    # link html/frontend data
    ln -s "$(pwd)/src" src-tauri/html

    substituteInPlace "$cargoDepsCopy"/*/libappindicator-sys-*/src/lib.rs \
      --replace-fail "libayatana-appindicator3.so.1" "${libayatana-appindicator}/lib/libayatana-appindicator3.so.1" || true
  '';

  configurePhase = ''
    runHook preConfigure
    cmakeConfigurePhase
    pnpmConfigHook
    runHook postConfigure
  '';

  tauriBuildFlags = [
    "--ignore-version-mismatches"
  ];

  buildPhase = ''
    ninjaBuildPhase
    cd ../..
    tauriBuildHook
  '';

  postInstall = ''
    mkdir -p "$out/lib/Vorion"
    ln -s "$out/lib/Vorion" "$out/lib/vorion"
    rm -rf "$out/lib/Vorion/injection"
    cp -r src-tauri/injection "$out/lib/Vorion" 2>/dev/null || true
    cp -r src "$out/lib/Vorion" 2>/dev/null || true
    
    # Install the CSP killer extension so plugins can bypass CSP
    mkdir -p "$out/lib/extension_webkit"
    cp src-tauri/extension_webkit/*.so "$out/lib/extension_webkit/" 2>/dev/null || true

    # Rename binary to match the desktop file
    if [ -f "$out/bin/Dorion" ]; then
      mv "$out/bin/Dorion" "$out/bin/Vorion"
    fi

    desktop-file-edit \
      --set-comment "Tiny alternative Discord client (with WebRTC support)" \
      --set-key="Exec" --set-value="Vorion %U" \
      --set-key="TryExec" --set-value="Vorion" \
      --set-key="StartupWMClass" --set-value="Vorion" \
      --set-key="StartupNotify" --set-value="true" \
      --set-key="Categories" --set-value="Network;InstantMessaging;Chat;" \
      --set-key="Terminal" --set-value="false" \
      --set-key="MimeType" --set-value="x-scheme-handler/discord" \
      "$out/share/applications/Vorion.desktop" || true
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --set WEBKIT_DISABLE_COMPOSITING_MODE 1
      --set WEBKIT_DISABLE_SANDBOX_THIS_IS_DANGEROUS 1
      --set WEBKIT_DISABLE_DMABUF_RENDERER 1
    )
  '';

  doCheck = false;

  env = {
    CI = "true";
    TAURI_RESOURCE_DIR = "${placeholder "out"}/lib";
  };

  meta = {
    homepage = "https://github.com/Zexolver/Vorion";
    description = "[LINUX ONLY] Fork of Dorion meant to package with its own WebRTC";
    license = lib.licenses.gpl3Only;
    mainProgram = "Vorion";
    platforms = lib.platforms.unix;
  };
})
