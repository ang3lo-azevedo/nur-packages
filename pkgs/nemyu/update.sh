#!/usr/bin/env bash
# Repins default.nix to the newest Nemyu release that ships a linux x86_64
# AppImage. The project lives on GitLab; newer releases are sometimes
# Windows-only, so pick the newest by date whose assets include a linux
# AppImage. The GitLab generic-package URL embeds the commit and pipeline id, so
# the full url is rewritten here too (not just version + hash).
#
# Needs: curl, jq, nix.
set -euo pipefail

api="https://gitlab.com/api/v4"
proj="nemyu-emulator%2Fnemyu"
nix="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/default.nix"

read -r tag url < <(
  curl -fsSL "$api/projects/$proj/releases?per_page=30" \
    | jq -r '
        [ .[]
          | . as $r
          | $r.assets.links[]
          | select(.url | test("linux-x86_64\\.AppImage$"))
          | {published: $r.released_at, tag: $r.tag_name, url: .url}
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

echo "nemyu: $tag"

sed -i -E \
  -e "s|(version = \")[^\"]*(\";)|\1${tag}\2|" \
  -e "s|(url = \")[^\"]*(\";)|\1${url}\2|" \
  -e "s|(hash = \")[^\"]*(\";)|\1${hash}\2|" \
  "$nix"
