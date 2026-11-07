#!/usr/bin/env bash
# Repins default.nix to the newest Horizon launcher release.
#
# Upstream cuts two kinds of releases: stable launcher builds tagged
# launcher@X.Y.Z, and a rolling "nightly" prerelease of the game itself. Only the
# launcher releases ship horizon-launcher-linux-x86_64.AppImage, so filter to
# those (tag starts with "launcher@", not a prerelease) and take the newest by
# date. The URL in default.nix templates off the tag, so only version and hash
# change.
#
# Needs: curl, jq, nix. Set GITHUB_TOKEN to avoid API rate limits.
set -euo pipefail

repo="horizon-rust/horizon"
nix="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/default.nix"

# Newest non-prerelease launcher release that ships the linux x86_64 AppImage.
read -r tag url < <(
  curl -fsSL ${GITHUB_TOKEN:+-H "Authorization: Bearer $GITHUB_TOKEN"} \
    "https://api.github.com/repos/$repo/releases?per_page=50" \
    | jq -r '
        [ .[]
          | select(.prerelease | not)
          | select(.tag_name | startswith("launcher@"))
          | . as $r
          | $r.assets[]
          | select(.name == "horizon-launcher-linux-x86_64.AppImage")
          | {published: $r.published_at, tag: $r.tag_name, url: .browser_download_url}
        ]
        | sort_by(.published) | last
        | "\(.tag) \(.url)"
      '
)
[[ -n ${tag:-} && -n ${url:-} ]] || {
  echo "no matching release/asset found" >&2
  exit 1
}

hash="$(nix store prefetch-file --json "$url" | jq -r .hash)"

echo "horizon-launcher: $tag"

sed -i -E \
  -e "s|(version = \")[^\"]*(\";)|\1${tag}\2|" \
  -e "s|(hash = \")[^\"]*(\";)|\1${hash}\2|" \
  "$nix"
