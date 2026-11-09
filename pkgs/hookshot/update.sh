#!/usr/bin/env bash
# Repins default.nix to the newest Hookshot release that ships an x86_64 AppImage.
# Tracks the Shakoquo AMD-fix fork for our RX 9060 XT eGPU.
#
# Upstream releases are tagged with feature names / fix versions, and the asset
# name embeds the commit (Hookshot-<version>-x86_64.AppImage). So fetch the
# newest release by date that actually has an x86_64 AppImage, and rewrite the
# full url, the version (the token from the asset name) and the hash.
#
# Needs: curl, jq, nix. Set GITHUB_TOKEN to avoid API rate limits.
set -euo pipefail

repo="Shakoquo/Hookshot"
nix="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/default.nix"

# Newest release by date that ships an x86_64 AppImage.
read -r url < <(
  curl -fsSL ${GITHUB_TOKEN:+-H "Authorization: Bearer $GITHUB_TOKEN"} \
    "https://api.github.com/repos/$repo/releases?per_page=30" \
    | jq -r '
        [ .[]
          | . as $r
          | $r.assets[]
          | select(.name | endswith("x86_64.AppImage"))
          | {published: $r.published_at, url: .browser_download_url}
        ]
        | sort_by(.published) | last | .url
      '
)
[[ -n ${url:-} ]] || {
  echo "no release with an x86_64 AppImage found" >&2
  exit 1
}

# Version is the token between "Hookshot-" and "-x86_64.AppImage" (the commit).
asset="${url##*/}"
version="${asset#Hookshot-}"
version="${version%-x86_64.AppImage}"

hash="$(nix store prefetch-file --json "$url" | jq -r .hash)"

echo "hookshot: $version"

sed -i -E \
  -e "s|(version = \")[^\"]*(\";)|\1${version}\2|" \
  -e "s|(url = \")[^\"]*(\";)|\1${url}\2|" \
  -e "s|(hash = \")[^\"]*(\";)|\1${hash}\2|" \
  "$nix"
