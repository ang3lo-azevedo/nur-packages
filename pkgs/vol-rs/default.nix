{
  lib,
  rustPlatform,
  fetchFromGitHub,
  makeWrapper,
}:

rustPlatform.buildRustPackage rec {
  pname = "vol-rs";
  version = "c93b75fde0ba71a3164c86d520571c58351dc64b";

  src = fetchFromGitHub {
    owner = "daffainfo";
    repo = "vol-rs";
    rev = version;
    hash = "sha256-ZalSSboslTk5wsr5dfo/WtE6n5+eoYR3HrNsTKWwaxI=";
  };

  cargoHash = "sha256-ofaqI1MtrC8A989CCGeiqQJFrptKMJsk18NnYNlUYFY=";

  nativeBuildInputs = [makeWrapper];

  # The test suite rebuilds the whole crate (about 14 minutes) for two tests
  # that only check how the plugins are registered.
  doCheck = false;

  # Share Volatility 3's symbol directory, which uses the same file layout.
  # vol-rs only downloads Windows kernel symbols, so it reads the Linux and
  # macOS ones Volatility 3 fetched, and it writes the Windows ones it builds
  # to the first directory listed, where Volatility 3 finds them in turn.
  postInstall = ''
    wrapProgram $out/bin/vol-rs \
      --run 'export VOLRS_SYMBOL_PATH="''${VOLRS_SYMBOL_PATH:+$VOLRS_SYMBOL_PATH:}''${XDG_DATA_HOME:-$HOME/.local/share}/volatility3/symbols"'
  '';

  meta = with lib; {
    description = "Volatility 3 ported to Rust. Same output, much faster.";
    homepage = "https://github.com/daffainfo/vol-rs";
    license = licenses.vol-sl;
    mainProgram = "vol-rs";
  };
}
