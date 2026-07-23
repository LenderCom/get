#!/bin/bash
# Rewrites the `agent` installer's pinned SAW_AGENT_TAG_DEV default to a given
# LenderCom/saw-agent-releases tag. The dev channel cuts several releases a
# day and nothing else keeps this default current — CI's `--dry-run` self-test
# never touches it (it fabricates its own fixture release), so a stale pin here
# 404s the real `curl -fsSL https://get.sawrun.com/agent | sh -s -- --channel dev`
# install silently until someone actually runs it.
#
# Usage: bump-dev-tag.sh <tag> [agent-script-path]
set -euo pipefail

tag="${1:?usage: bump-dev-tag.sh <tag> [agent-script-path]}"
script_path="${2:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/agent}"

[ -f "$script_path" ] || { echo "no such file: $script_path" >&2; exit 1; }
grep -q '^SAW_AGENT_TAG_DEV=' "$script_path" || {
  echo "no SAW_AGENT_TAG_DEV default line found in $script_path" >&2
  exit 1
}

sed -i.bak -E "s/^SAW_AGENT_TAG_DEV=\"\\\$\\{SAW_AGENT_TAG_DEV:-[^}]*\\}\"/SAW_AGENT_TAG_DEV=\"\${SAW_AGENT_TAG_DEV:-${tag}}\"/" "$script_path"
rm -f "$script_path.bak"

echo "Bumped SAW_AGENT_TAG_DEV default to ${tag} in ${script_path}"
