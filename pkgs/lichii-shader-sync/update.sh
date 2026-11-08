#!/usr/bin/env bash
# Repins default.nix to the newest Lichii Shader Sync app release.
#
# The app releases are tagged vX.Y.Z and are the only ones marked "latest" (shader
# packs are separate, non-latest releases tagged by title id), so the latest
# release is always the app. The URL in default.nix templates off `version`, so
# only version and hash change.
#
# Needs: curl, jq, nix. Set GITHUB_TOKEN to avoid API rate limits.
set -euo pipefail

repo="oceanpacificpeace/lichii-shader-sync"
nix="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/default.nix"

tag="$(
  curl -fsSL ${GITHUB_TOKEN:+-H "Authorization: Bearer $GITHUB_TOKEN"} \
    "https://api.github.com/repos/$repo/releases/latest" | jq -r .tag_name
)"
[[ -n ${tag:-} && $tag != null ]] || {
  echo "no latest release found" >&2
  exit 1
}

version="${tag#v}"
url="https://github.com/$repo/releases/download/${tag}/lichii-sync-linux-amd64"
hash="$(nix store prefetch-file --json "$url" | jq -r .hash)"

echo "lichii-shader-sync: $version"

sed -i -E \
  -e "s|(version = \")[^\"]*(\";)|\1${version}\2|" \
  -e "s|(hash = \")[^\"]*(\";)|\1${hash}\2|" \
  "$nix"
