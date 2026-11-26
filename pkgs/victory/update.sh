#!/usr/bin/env bash
# Repins default.nix to the latest commit on Belobug/VIctory-Belobug-AMD main.
set -euo pipefail

nix="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/default.nix"
repo="Belobug/VIctory-Belobug-AMD"

read -r rev date < <(
  curl -fsSL ${GITHUB_TOKEN:+-H "Authorization: Bearer $GITHUB_TOKEN"} \
    "https://api.github.com/repos/$repo/commits/main" \
    | jq -r '"\(.sha) \(.commit.committer.date | split("T")[0])"'
)
[[ -n ${rev:-} && -n ${date:-} ]] || {
  echo "failed to resolve latest commit for $repo" >&2
  exit 1
}

hash="$(nix run nixpkgs#nix-prefetch-github -- Belobug VIctory-Belobug-AMD --rev "$rev" | jq -r .hash)"

echo "victory: 0.1.0-unstable-$date ($rev)"

sed -i -E \
  -e "s|(version = \"0\\.1\\.0-unstable-)[^\"]*(\";)|\1${date}\2|" \
  -e "s|(rev = \")[^\"]*(\";)|\1${rev}\2|" \
  -e "s|(hash = \")[^\"]*(\";)|\1${hash}\2|" \
  "$nix"
