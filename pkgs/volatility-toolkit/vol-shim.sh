#!@shell@
# vol-rs only accepts fully qualified plugin names (windows.info.Info), while
# vol-analyze passes the short form that Volatility 3 resolves itself.
plugins=@plugins@

# Prefer the user's own Volatility 3 install, which may carry local patches.
vol3() {
  local vol3
  vol3=$(type -P volatility || type -P vol3 || echo @vol3@)
  exec "$vol3" -p "@vol3PluginDirs@" "$@"
}

args=()
for arg in "$@"; do
  if [[ $arg == *.* ]] && ! grep -qxF -- "$arg" "$plugins"; then
    mapfile -t matches < <(grep -xE -- "${arg//./\\.}\\.[A-Za-z0-9_]+" "$plugins")
    (( ${#matches[@]} == 1 )) && arg=${matches[0]}
  fi
  # Python plugins bundled for Volatility 3 have no vol-rs port to try first.
  [[ $arg =~ ^(windows|linux|mac)\. ]] && ! grep -qxF -- "$arg" "$plugins" && vol3 "$@"
  # The rules below route around vol-rs bugs where it returns wrong results but
  # exits 0, so the fallback further down never triggers. Drop each rule once
  # vol-rs matches Volatility 3 on the same dump.

  # FIXME(vol-rs): cmdscan and consoles misparse the console buffers. Both return
  # the same rows, blank HistoryBuffer entries and fragments of PATH, while
  # Volatility 3 returns the real _COMMAND_HISTORY and _CONSOLE_INFORMATION fields.
  [[ $arg == windows.cmdscan.* || $arg == windows.consoles.* ]] && vol3 "$@"

  # FIXME(vol-rs): on Linux (tested on linux-sample-1.bin, Debian kernel 3.2),
  # bash, proc.Maps, mountinfo and elfs return no rows at all; modxview reports
  # "In scan" False for every module; pslist drops creation times, sockstat
  # IPv6 addresses, and ip the NetNS and interface flags.
  [[ $arg == linux.* ]] && vol3 "$@"

  # FIXME(vol-rs): timeliner returns about half of Volatility 3's rows, with
  # different counts per source plugin (fewer MFTScan, more SymlinkScan), even
  # though those plugins match when run on their own.
  [[ $arg == timeliner.* ]] && vol3 "$@"

  # Not a known bug: vol-rs has never been compared with Volatility 3 on a macOS
  # dump. Given the Linux results, use Volatility 3 until someone checks.
  [[ $arg == mac.* ]] && vol3 "$@"
  args+=("$arg")
done

# vol-rs cannot fetch Windows kernel symbols and lacks some plugins, so a failed
# run is retried with Volatility 3. Output is buffered so a partial vol-rs
# result never ends up in front of the retry's output.
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
