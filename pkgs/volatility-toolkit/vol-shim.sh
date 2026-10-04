#!@shell@
# vol-analyze passes short plugin names (windows.info). They are expanded to the
# fully qualified form (windows.info.Info) so the routing rules below can match
# them against the list of plugins vol-rs has. vol-rs resolves short names
# itself, so an unexpanded one would slip past those rules.
plugins=@plugins@

# Prefer the user's own Volatility 3 install, which may carry local patches.
vol3() {
  local vol3
  vol3=$(type -P volatility || type -P vol3 || echo @vol3@)
  exec "$vol3" -p "@vol3PluginDirs@" "$@"
}

args=()
for arg in "$@"; do
  if [[ $arg == *.* || $arg =~ ^[a-z_]+$ ]] && ! grep -qxF -- "$arg" "$plugins"; then
    mapfile -t matches < <(grep -xE -- "${arg//./\\.}\\.[A-Za-z0-9_]+" "$plugins")
    (( ${#matches[@]} == 1 )) && arg=${matches[0]}
  fi
  # Python plugins bundled for Volatility 3 have no vol-rs port to try first.
  [[ $arg =~ ^(windows|linux|mac)\. ]] && ! grep -qxF -- "$arg" "$plugins" && vol3 "$@"
  # The rule below routes around a vol-rs result that differs from Volatility 3
  # but exits 0, so the fallback further down never triggers. Drop it once
  # vol-rs matches Volatility 3 on the same dump.

  # FIXME(vol-rs): https://github.com/daffainfo/vol-rs/issues/7
  # With --plugin-filter both print the same rows, but an unfiltered timeliner
  # runs its plugins in a different order than Volatility 3 2.28.2. timeliner
  # prints the rows so far again after each plugin, so the totals differ: 87,235
  # rows against 137,769 on Volatility's Windows 10 test dump.
  [[ $arg == timeliner.* ]] && vol3 "$@"

  # Not a known bug: upstream has not run the macOS plugins on a real capture
  # yet, and neither have we. Use Volatility 3 until someone checks.
  [[ $arg == mac.* ]] && vol3 "$@"
  args+=("$arg")
done

# vol-rs only downloads Windows kernel symbols and may not read every dump
# Volatility 3 can, so a failed run is retried with Volatility 3. Output is
# buffered so a partial vol-rs result never ends up in front of the retry's
# output.
out=$(mktemp) err=$(mktemp)

if @vol@ "${args[@]}" >"$out" 2>"$err"; then
  cat "$out"
  cat "$err" >&2
  rm -f "$out" "$err"
  exit 0
fi

echo "[vol-rs failed, retrying with Volatility 3] $(tail -1 "$err")" >&2
rm -f "$out" "$err"
vol3 "$@"
