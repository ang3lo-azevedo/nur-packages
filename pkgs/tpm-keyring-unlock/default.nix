{
  lib,
  stdenv,
  bash,
  coreutils,
  gawk,
  gnugrep,
  makeWrapper,
  mokutil,
  pam,
  tpm2-tools,
  util-linux,
  src,
}:
stdenv.mkDerivation {
  pname = "tpm-keyring-unlock";
  version = "unstable-2026-09-07";
  inherit src;

  nativeBuildInputs = [makeWrapper];
  buildInputs = [pam];
  dontBuild = true;

  installPhase = ''
    mkdir -p "$out/lib/security" "$out/bin" "$out/libexec"

    $CC -Wall -Wextra -fPIC -shared \
      -DHELPER_PATH=\"/run/current-system/sw/bin/tpm-keyring-unseal\" \
      -o "$out/lib/security/pam_tpm_keyring_authtok.so" \
      pam/pam_tpm_keyring_authtok.c \
      -I${pam}/include -L${pam}/lib -lpam

    substitute pam/tpm-keyring-unseal.sh "$out/bin/tpm-keyring-unseal" \
      --replace-fail "/usr/bin/env bash" "${bash}/bin/bash" \
      --replace-fail "tpm2_createprimary" "${tpm2-tools}/bin/tpm2_createprimary" \
      --replace-fail "tpm2_load" "${tpm2-tools}/bin/tpm2_load" \
      --replace-fail "tpm2_startauthsession" "${tpm2-tools}/bin/tpm2_startauthsession" \
      --replace-fail "tpm2_policypcr" "${tpm2-tools}/bin/tpm2_policypcr" \
      --replace-fail "tpm2_unseal" "${tpm2-tools}/bin/tpm2_unseal" \
      --replace-fail "tpm2_flushcontext" "${tpm2-tools}/bin/tpm2_flushcontext"
    chmod 0500 "$out/bin/tpm-keyring-unseal"

    substitute bin/seal.sh "$out/libexec/tpm-keyring-seal" \
      --replace-fail "/usr/bin/env bash" "${bash}/bin/bash"
    substitute bin/lib.sh "$out/libexec/lib.sh" \
      --replace-fail "/usr/bin/env bash" "${bash}/bin/bash"
    chmod 0500 "$out/libexec/tpm-keyring-seal" "$out/libexec/lib.sh"
    makeWrapper "$out/libexec/tpm-keyring-seal" "$out/bin/tpm-keyring-seal" \
      --prefix PATH : "${lib.makeBinPath [tpm2-tools coreutils util-linux gnugrep gawk mokutil]}"
  '';
}
