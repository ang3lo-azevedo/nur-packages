#!/usr/bin/env bash
# Repins default.nix to the newest Eglantine nx2 pre-release AppImage.
#
# nvfetcher can't track this: the asset URL needs both the build-NN tag (in the
# path) and the full commit SHA (in the filename), but nvfetcher templates a
# single version string, and the releases are prereleases its release tracker
# skips. So fetch the two values from the API and rewrite them here.
#
# Needs: curl, jq, nix. Set GITHUB_TOKEN to avoid API rate limits.
set -euo pipefail

repo="Djihads80/Eglantine"
nix="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/default.nix"

# Newest build-* release that ships a linux x86_64 PGO AppImage.
read -r tag url < <(
  curl -fsSL ${GITHUB_TOKEN:+-H "Authorization: Bearer $GITHUB_TOKEN"} \
    "https://api.github.com/repos/$repo/releases?per_page=30" \
    | jq -r '
        [ .[]
          | select(.tag_name | startswith("build-")) as $r
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

# The URL is the only place that carries the commit: it is in the filename.
commit="$(basename "$url" | sed -E 's/^eglantine-([0-9a-f]+)-linux.*/\1/')"
hash="$(nix store prefetch-file --json "$url" | jq -r .hash)"

echo "eglantine: $tag ($commit)"

sed -i -E \
  -e "s|(version = \")[^\"]*(\";)|\1${tag}\2|" \
  -e "s|(commit = \")[^\"]*(\";)|\1${commit}\2|" \
  -e "s|(hash = \")[^\"]*(\";)|\1${hash}\2|" \
  "$nix"
