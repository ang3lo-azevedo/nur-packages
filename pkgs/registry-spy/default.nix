{
  lib,
  python3Packages,
  callPackage,
  copyDesktopItems,
  makeDesktopItem,
}: let
  sources = callPackage ../../_sources/generated.nix {};
in
  python3Packages.buildPythonApplication {
    pname = "registry-spy";
    version = sources.registry-spy.version;
    format = "setuptools";

    src = sources.registry-spy.src;

    nativeBuildInputs = with python3Packages; [setuptools] ++ [copyDesktopItems];

    propagatedBuildInputs = [
      python3Packages.pyside6
      # registry-spy pins python-registry==1.3.1, so keep that label. nixpkgs' new
      # pythonMetadataCheckPhase rejects the package because nixpkgs set its version
      # attr out of sync with the source .dist-info METADATA; skip that check here.
      (python3Packages.python-registry.overridePythonAttrs (_: {
        version = "1.3.1";
        name = "python-registry-1.3.1";
        dontCheckPythonMetadata = true;
      }))
    ];

    desktopItems = [
      (makeDesktopItem {
        name = "registry-spy";
        exec = "registryspy";
        desktopName = "Registry Spy";
        comment = "Cross-platform Windows Registry browser";
        categories = ["Utility" "System"];
      })
    ];

    doCheck = false;

    meta = with lib; {
      description = "Cross-platform Windows Registry browser";
      homepage = "https://github.com/andyjsmith/Registry-Spy";
      license = licenses.gpl3;
      maintainers = [];
      platforms = platforms.all;
    };
  }
