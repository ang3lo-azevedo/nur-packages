#!@shell@
# vol-rs only accepts fully qualified plugin names (windows.info.Info), while
# vol-analyze passes the short form that Volatility 3 resolves itself.
plugins=@plugins@

args=()
for arg in "$@"; do
  if [[ $arg == *.* ]] && ! grep -qxF -- "$arg" "$plugins"; then
    mapfile -t matches < <(grep -xE -- "${arg//./\\.}\\.[A-Za-z0-9_]+" "$plugins")
    (( ${#matches[@]} == 1 )) && arg=${matches[0]}
  fi
  args+=("$arg")
done

# vol-rs cannot fetch Windows kernel symbols and lacks some plugins, so a failed
# run is retried with Volatility 3. Output is buffered so a partial vol-rs
# result never ends up in front of the retry's output.
out=$(mktemp) err=$(mktemp)
trap 'rm -f "$out" "$err"' EXIT

if @vol@ "${args[@]}" >"$out" 2>"$err"; then
  cat "$out"
  cat "$err" >&2
  exit 0
fi

# Prefer the user's own Volatility 3 install, which may carry local patches.
vol3=$(command -v volatility || command -v vol3 || echo @vol3@)
echo "[vol-rs failed, retrying with Volatility 3] $(tail -1 "$err")" >&2
exec "$vol3" "$@"
