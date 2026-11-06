#!/usr/bin/env bash
# Repins default.nix to the newest Eglantine nx2 AppImage.
#
# nvfetcher can't track this: the releases are prereleases its release tracker
# skips. So fetch the newest release by publish date from the API and rewrite it
# here. Upstream tags several kinds (build-NN, daily-*, v*, branch-<name>); the
# newest by date wins whatever it is, including experimental branch builds.
#
# Prefer the release's PGO AppImage (profile-guided, faster) but fall back to the
# plain linux-x86_64 AppImage when that build does not ship a PGO one, so a
# branch build without PGO is still taken rather than skipped. The asset name
# therefore varies, so the full url is rewritten here too (not just version +
# hash).
#
# Needs: curl, jq, nix. Set GITHUB_TOKEN to avoid API rate limits.
set -euo pipefail

repo="Djihads80/Eglantine"
nix="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/default.nix"

# Newest release by date that ships any linux x86_64 AppImage, preferring the
# PGO asset within that release.
read -r tag url < <(
  curl -fsSL ${GITHUB_TOKEN:+-H "Authorization: Bearer $GITHUB_TOKEN"} \
    "https://api.github.com/repos/$repo/releases?per_page=30" \
    | jq -r '
        [ .[]
          | . as $r
          | ([$r.assets[] | select(.name | test("linux-x86_64-pgo\\.AppImage$")) | .browser_download_url]) as $pgo
          | ([$r.assets[] | select(.name | test("linux-x86_64\\.AppImage$")) | .browser_download_url]) as $plain
          | ($pgo[0] // $plain[0]) as $url
          | select($url != null)
          | {published: $r.published_at, tag: $r.tag_name, url: $url}
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
  -e "s|(url = \")[^\"]*(\";)|\1${url}\2|" \
  -e "s|(hash = \")[^\"]*(\";)|\1${hash}\2|" \
  "$nix"
