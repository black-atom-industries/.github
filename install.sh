#!/usr/bin/env bash
# Links AGENTS.md into the org folder, where every session in a sibling repo loads it.
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ln -sfn "$(basename "$repo")/AGENTS.md" "$repo/../AGENTS.md"
echo "Linked $(dirname "$repo")/AGENTS.md"
