#!/bin/bash
# Rewrites the `agent` installer's built-in FALLBACK release tag for a channel to a
# given LenderCom/saw-agent-releases tag.
#
# The installer resolves the channel's current release from the releases Atom feed at
# install time, so these constants are only reached when that feed is unreachable.
# They still have to be kept alive: the dev channel prunes old prereleases, so a
# fallback left to rot stops being "old but installable" and becomes a 404 — which is
# what both dev-v0.1.1-dev.21 and the never-published v0.1.0 had already become.
#
# Usage: bump-fallback-tag.sh <dev|stable> <tag> [agent-script-path]
set -euo pipefail

channel="${1:?usage: bump-fallback-tag.sh <dev|stable> <tag> [agent-script-path]}"
tag="${2:?usage: bump-fallback-tag.sh <dev|stable> <tag> [agent-script-path]}"
script_path="${3:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/agent}"

case "$channel" in
  dev) var=SAW_AGENT_TAG_DEV_FALLBACK ;;
  stable) var=SAW_AGENT_TAG_STABLE_FALLBACK ;;
  *)
    echo "channel must be 'dev' or 'stable', got '$channel'" >&2
    exit 1
    ;;
esac

[ -f "$script_path" ] || { echo "no such file: $script_path" >&2; exit 1; }
grep -q "^${var}=" "$script_path" || {
  echo "no ${var} line found in $script_path" >&2
  exit 1
}

sed -i.bak -E "s|^${var}=\".*\"\$|${var}=\"${tag}\"|" "$script_path"
rm -f "$script_path.bak"

grep -q "^${var}=\"${tag}\"\$" "$script_path" || {
  echo "failed to rewrite ${var} to ${tag} in ${script_path}" >&2
  exit 1
}

echo "Bumped ${var} to ${tag} in ${script_path}"
