{
  lib,
  stdenvNoCC,
  python3,
  makeWrapper,
  fetchFromGitHub,
  py2neo,
}: let
  python = python3.withPackages (ps:
    [py2neo]
    ++ (with ps; [pandas prettytable]));
in
  stdenvNoCC.mkDerivation {
    pname = "bloodhound-quickwin";
    version = "0-unstable-2025-04-04";

    src = fetchFromGitHub {
      owner = "kaluche";
      repo = "bloodhound-quickwin";
      rev = "b074e80e63acc77fe44095d6d631dd58144e9fce";
      hash = "sha256-PP6+yAGs9w1eNgN8gacb98arfPPLR5HttLlai0RsXkU=";
    };

    nativeBuildInputs = [makeWrapper];

    dontBuild = true;

    # A single script, run against a Neo4j already populated by BloodHound
    installPhase = ''
      runHook preInstall
      install -Dm644 bhqc.py $out/share/bloodhound-quickwin/bhqc.py
      makeWrapper ${python}/bin/python $out/bin/bloodhound-quickwin \
        --add-flags $out/share/bloodhound-quickwin/bhqc.py
      runHook postInstall
    '';

    meta = with lib; {
      description = "Quick wins from a BloodHound Neo4j database via Cypher queries";
      homepage = "https://github.com/kaluche/bloodhound-quickwin";
      # No license file upstream
      license = licenses.unfree;
      maintainers = [];
      mainProgram = "bloodhound-quickwin";
      platforms = platforms.linux;
    };
  }
