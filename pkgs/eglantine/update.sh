#!/usr/bin/env bash
# Repins default.nix to the newest Eglantine nx2 release that ships the PGO
# AppImage.
#
# nvfetcher can't track this: the releases are prereleases its release tracker
# skips. So fetch the newest release by publish date from the API and rewrite it
# here. Upstream tags several kinds (build-NN, daily-*, v*, branch-<name>); the
# branch-<name> ones are throwaway testing builds and do not ship a PGO AppImage,
# so requiring the linux-x86_64-pgo asset keeps us on the real (PGO) builds and
# skips the testing ones. The newest PGO release by date wins whatever its tag.
#
# Needs: curl, jq, nix. Set GITHUB_TOKEN to avoid API rate limits.
set -euo pipefail

repo="Djihads80/Eglantine"
nix="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/default.nix"

# Newest release by date that ships the linux x86_64 PGO AppImage.
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

echo "eglantine: $tag"

sed -i -E \
  -e "s|(version = \")[^\"]*(\";)|\1${tag}\2|" \
  -e "s|(hash = \")[^\"]*(\";)|\1${hash}\2|" \
  "$nix"
