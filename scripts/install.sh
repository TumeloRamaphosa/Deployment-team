#!/usr/bin/env bash
# Install the Studex Deployment Team into one repository checkout.
# Usage: scripts/install.sh /path/to/target-repo
# Safe to run twice. Never overwrites an existing AGENTS.md or copilot-instructions.md.
set -euo pipefail

PACK="$(cd "$(dirname "$0")/.." && pwd)"
TARGET="${1:?usage: install.sh /path/to/target-repo}"
[ -d "$TARGET/.git" ] || { echo "not a git repo: $TARGET" >&2; exit 1; }

mkdir -p "$TARGET/.github/agents" "$TARGET/.github/skills" "$TARGET/.github/workflows" "$TARGET/.github/ISSUE_TEMPLATE"

# Agents + skills: always refreshed from the pack (the pack is the source of truth)
cp "$PACK"/agents/*.agent.md "$TARGET/.github/agents/"
for s in "$PACK"/skills/*/; do
  name="$(basename "$s")"
  rm -rf "$TARGET/.github/skills/$name"
  cp -R "$s" "$TARGET/.github/skills/$name"
done

# Workflows + templates: refreshed (they are pack-owned files)
cp "$PACK/template/.github/workflows/deploy-guard.yml" "$TARGET/.github/workflows/"
cp "$PACK/template/.github/ISSUE_TEMPLATE/agent-task.yml" "$TARGET/.github/ISSUE_TEMPLATE/"

# Files a repo may already have customised: only create when missing
copy_if_missing() {
  if [ -e "$2" ]; then echo "kept existing $(basename "$2")"; else cp "$1" "$2"; fi
}
copy_if_missing "$PACK/template/AGENTS.md" "$TARGET/AGENTS.md"
copy_if_missing "$PACK/template/.github/copilot-instructions.md" "$TARGET/.github/copilot-instructions.md"
copy_if_missing "$PACK/template/.github/pull_request_template.md" "$TARGET/.github/pull_request_template.md"
copy_if_missing "$PACK/template/.github/workflows/copilot-setup-steps.yml" "$TARGET/.github/workflows/copilot-setup-steps.yml"

# Make sure common secret files are ignored
touch "$TARGET/.gitignore"
for p in '*.env' '.env*' '!.env.example' 'secrets.*' '*.pem' '*.key' 'service-account*.json' '.vercel'; do
  grep -qxF -- "$p" "$TARGET/.gitignore" || echo "$p" >> "$TARGET/.gitignore"
done

echo "Installed Studex Deployment Team into $TARGET"
