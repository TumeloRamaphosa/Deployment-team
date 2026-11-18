#!/usr/bin/env bash
# Roll the Studex Deployment Team out to many repos — one pull request per repo, never a push to main.
#
# Usage:
#   scripts/rollout.sh                      # dry run: list repos that would get a PR
#   scripts/rollout.sh --apply              # open PRs on every repo in repos.txt
#   scripts/rollout.sh --apply owner/repo   # open a PR on one repo
#
# Needs: gh (logged in: `gh auth login`), git, bash.
# repos.txt: one owner/repo per line; lines starting with # are skipped.
set -euo pipefail

PACK="$(cd "$(dirname "$0")/.." && pwd)"
BRANCH="studex/deployment-team"
APPLY=false
[ "${1:-}" = "--apply" ] && { APPLY=true; shift; }

if [ $# -gt 0 ]; then REPOS=("$@")
else mapfile -t REPOS < <(grep -vE '^\s*(#|$)' "$PACK/repos.txt")
fi

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

ok=0; skip=0; fail=0
for repo in "${REPOS[@]}"; do
  if ! $APPLY; then echo "would open PR: $repo"; continue; fi
  echo "== $repo"
  dir="$WORK/${repo//\//__}"
  if ! gh repo clone "$repo" "$dir" -- --depth 1 -q; then echo "  clone failed"; fail=$((fail+1)); continue; fi
  if [ -z "$(git -C "$dir" rev-parse --verify -q HEAD)" ]; then echo "  empty repo, skipped"; skip=$((skip+1)); continue; fi
  if gh pr list -R "$repo" --head "$BRANCH" --state open --json number -q '.[0].number' | grep -q .; then
    echo "  PR already open, skipped"; skip=$((skip+1)); continue
  fi
  git -C "$dir" switch -c "$BRANCH" -q
  bash "$PACK/scripts/install.sh" "$dir" >/dev/null
  git -C "$dir" add -A
  if git -C "$dir" diff --cached --quiet; then echo "  already up to date"; skip=$((skip+1)); continue; fi
  git -C "$dir" commit -q -m "chore: add Studex Deployment Team (Copilot lead engineer + skills)"
  if git -C "$dir" -c push.negotiate=true push -q -u origin "$BRANCH" \
     && gh pr create -R "$repo" --head "$BRANCH" --title "Add Studex Deployment Team (Copilot-led)" \
          --body-file "$PACK/template/ROLLOUT_PR_BODY.md" >/dev/null; then
    echo "  PR opened"; ok=$((ok+1))
  else
    echo "  push/PR failed"; fail=$((fail+1))
  fi
done

$APPLY && echo "done: $ok opened, $skip skipped, $fail failed"
