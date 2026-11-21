{
  lib,
  stdenv,
  callPackage,
  ostree,
  flatpak,
  autoPatchelfHook,
  wrapGAppsHook4,
  webkitgtk_6_0,
  gtk4,
  glib,
  glib-networking,
  gsettings-desktop-schemas,
  mpv-unwrapped,
}:
let
  sources = callPackage ../../_sources/generated.nix { };
  pname = "aiostreams-desktop";
  inherit (sources.aiostreams-desktop) version src;
in
stdenv.mkDerivation {
  inherit pname version src;

  preferLocalBuild = true;
  requiredSystemFeatures = ["local"];

  nativeBuildInputs = [
    ostree
    flatpak
    autoPatchelfHook
    wrapGAppsHook4
  ];

  buildInputs = [
    webkitgtk_6_0
    gtk4
    glib
    glib-networking
    gsettings-desktop-schemas
    mpv-unwrapped
  ];

  unpackPhase = ''
    ostree init --repo=repo --mode=bare-user-only
    flatpak build-import-bundle repo $src
    ostree checkout --repo=repo app/io.github.viren070.aiostreams/x86_64/master extracted
  '';

  installPhase = ''
    mkdir -p $out/bin $out/lib/aiostreams-desktop $out/share
    cp -r extracted/files/lib/aiostreams-desktop/* $out/lib/aiostreams-desktop/
    cp -r extracted/files/share/* $out/share/

    ln -s $out/lib/aiostreams-desktop/aiostreams-desktop $out/bin/aiostreams-desktop
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --set AIOSTREAMS_LIBMPV "${mpv-unwrapped}/lib/libmpv.so"
      --set AIOSTREAMS_WEB_DIR "$out/lib/aiostreams-desktop/web"
    )
  '';

  meta = with lib; {
    description = "The AIOStreams app in a native window, playing through mpv";
    homepage = "https://github.com/Viren070/AIOStreams";
    license = licenses.agpl3Only;
    platforms = [ "x86_64-linux" ];
    mainProgram = "aiostreams-desktop";
  };
}
