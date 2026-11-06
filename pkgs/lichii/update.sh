#!/usr/bin/env bash
# Repins default.nix to the newest Lichii (zortos293's Eglantine fork) nx2
# pre-release AppImage.
#
# nvfetcher can't track this: the releases are prereleases its release tracker
# skips. So fetch the newest release by publish date from the API and rewrite it
# here. The asset name is fixed (lichii-linux-x86_64-pgo.AppImage), so the URL
# templates off the tag alone; the newest by date wins whatever its tag is.
#
# Needs: curl, jq, nix. Set GITHUB_TOKEN to avoid API rate limits.
set -euo pipefail

repo="zortos293/Lichii"
asset="lichii-linux-x86_64-pgo.AppImage"
nix="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/default.nix"

# Newest release by date that ships the linux x86_64 PGO AppImage.
read -r tag url < <(
  curl -fsSL ${GITHUB_TOKEN:+-H "Authorization: Bearer $GITHUB_TOKEN"} \
    "https://api.github.com/repos/$repo/releases?per_page=30" \
    | jq -r --arg asset "$asset" '
        [ .[]
          | . as $r
          | $r.assets[]
          | select(.name == $asset)
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

echo "lichii: $tag"

sed -i -E \
  -e "s|(version = \")[^\"]*(\";)|\1${tag}\2|" \
  -e "s|(hash = \")[^\"]*(\";)|\1${hash}\2|" \
  "$nix"
