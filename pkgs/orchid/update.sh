#!/usr/bin/env bash
# Repins default.nix to the newest Orchid nx2 AppImage.
#
# nvfetcher can't track this reliably (rapid-fire point releases, asset name
# templated off the tag), so fetch the newest release by publish date from the
# API and rewrite it here. Every release ships
# orchid-<tag>-linux-x86_64-pgo.AppImage, and the tag doubles as `version`, so
# the URL in default.nix templates off the tag; only version and hash change.
#
# Needs: curl, jq, nix. Set GITHUB_TOKEN to avoid API rate limits.
set -euo pipefail

repo="MythosOfs/Orchid"
nix="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/default.nix"

# Newest release by date that ships a linux x86_64 PGO AppImage.
read -r tag url < <(
  curl -fsSL ${GITHUB_TOKEN:+-H "Authorization: Bearer $GITHUB_TOKEN"} \
    "https://api.github.com/repos/$repo/releases?per_page=30" \
    | jq -r '
        [ .[]
          | . as $r
          | $r.assets[]
          | select(.name | test("linux-x86_64-pgo\\.AppImage$"))
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

echo "orchid: $tag"

sed -i -E \
  -e "s|(version = \")[^\"]*(\";)|\1${tag}\2|" \
  -e "s|(hash = \")[^\"]*(\";)|\1${hash}\2|" \
  "$nix"
