{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage rec {
  pname = "unifiedlog-iterator";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "mandiant";
    repo = "macos-UnifiedLogs";
    tag = "v${version}";
    hash = "sha256-S1Pi/bs6DZe3/gSruFcd7gQCw9ojBjxU21n6Njcy65E=";
  };

  # The binary is a workspace of its own under examples/, which upstream ships
  # without a lockfile, so one is generated and kept here
  cargoRoot = "examples";
  buildAndTestSubdir = "examples";
  cargoLock.lockFile = ./Cargo.lock;

  postPatch = ''
    ln -s ${./Cargo.lock} examples/Cargo.lock
  '';

  meta = with lib; {
    description = "Parser for Apple Unified Logs (tracev3) that runs without macOS";
    homepage = "https://github.com/mandiant/macos-UnifiedLogs";
    license = licenses.asl20;
    maintainers = [];
    mainProgram = "unifiedlog_iterator";
    platforms = platforms.unix;
  };
}
