#!/usr/bin/env bash
# Repins default.nix to the latest Sunbird loader version and hash.
set -euo pipefail

nix="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/default.nix"
site="https://assets.sunbird.tools"

version="$(curl -fsSL "$site/version.json" | jq -r '.loader // empty')"
[[ -n ${version:-} ]] || {
  echo "no loader version found in version.json" >&2
  exit 1
}

hash="$(nix store prefetch-file --json "$site/plugins/libphoenix-linux-x86_64.so" | jq -r .hash)"

echo "sunbird: $version"

sed -i -E \
  -e "s|(version = \")[^\"]*(\";)|\1${version}\2|" \
  -e "s|(hash = \")[^\"]*(\";)|\1${hash}\2|" \
  "$nix"
