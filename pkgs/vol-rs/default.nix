{
  lib,
  rustPlatform,
  fetchFromGitHub,
  makeWrapper,
  volatility3,
}:

rustPlatform.buildRustPackage rec {
  pname = "vol-rs";
  version = "6ece85d645786ceb768329045af8c59996cd334d";

  src = fetchFromGitHub {
    owner = "daffainfo";
    repo = "vol-rs";
    rev = version;
    hash = "sha256-x0CiK4NuZa/+57jL0kZiFURUZnDqBZoseigZPMFJ/CM=";
  };

  cargoHash = "sha256-eQRMP4h73UsqTtSM2TQ/on+KwNCbhq/XfIEEh20qf6I=";

  nativeBuildInputs = [makeWrapper];

  # vol-rs reads Volatility 3's generic ISF files (netscan, registry, services,
  # callbacks, mbr) but does not ship them. Only the source tree is used, so the
  # unfree volatility3 derivation itself is never built.
  postInstall = ''
    wrapProgram $out/bin/vol-rs \
      --suffix VOLRS_SYMBOL_PATH : ${volatility3.src}/volatility3/framework/symbols
    ln -s $out/bin/vol-rs $out/bin/vol
  '';

  meta = with lib; {
    description = "Volatility 3 ported to Rust. Same output, much faster.";
    homepage = "https://github.com/daffainfo/vol-rs";
    license = licenses.mit;
    mainProgram = "vol-rs";
  };
}
