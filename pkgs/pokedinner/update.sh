#!/usr/bin/env bash
# Repins default.nix to the newest PokeDinner linux x86_64 AppImage release.
#
# The repo lives on Eden's Forgejo instance, not GitHub, so nvfetcher's release
# trackers don't reach it; the Forgejo API is Gitea-compatible, so query it the
# same way. The linux asset name carries only the semver tag (no commit, unlike
# eglantine), so version + hash are all we rewrite.
#
# Needs: curl, jq, nix.
set -euo pipefail

api="https://git.eden-emu.dev/api/v1"
repo="Franseven/PokeDinner-a-Eglantine-Fork"
nix="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/default.nix"

# Newest release that ships a linux x86_64 AppImage.
read -r tag url < <(
  curl -fsSL "$api/repos/$repo/releases?limit=30" \
    | jq -r '
        [ .[]
          | .tag_name as $tag
          | .assets[]
          | select(.name | test("linux-x86_64\\.AppImage$"))
          | {published: .created_at, tag: $tag, url: .browser_download_url}
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

echo "pokedinner: $tag"

sed -i -E \
  -e "s|(version = \")[^\"]*(\";)|\1${tag}\2|" \
  -e "s|(hash = \")[^\"]*(\";)|\1${hash}\2|" \
  "$nix"
