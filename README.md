# Studex Deployment Team + Skills Vault

The engineering team for every Studex Group repo, **led by GitHub Copilot**, plus the **Skills Vault** that all our agents (Copilot, Claude Code, Foreman, Gemini, Codex, Cursor) load from. Agent Skills (`SKILL.md`) is an open standard, so one vault serves every tool.

| # | Member | Lane |
|---|---|---|
| 1 | GitHub Copilot | Lead engineer — plans, code, PRs, review, security |
| 2 | Google — Gemini Spark | Google Cloud (Cloud Run, Firestore, Workspace) |
| 3 | Vercel — Foreman | Sites & dashboards; issue → reviewed draft PR factory |
| 4 | Cloudflare runners | Edge (Workers, DNS, R2) + ephemeral CI runners |
| 5 | Supabase team | Postgres, migrations, RLS, edge functions |

Roster, label routing and open-source fallbacks: [`TEAM.md`](TEAM.md).

## What's in the vault

```
agents/     9 Copilot custom agents (lead-engineer, architect, reviewer, security-officer,
            release-engineer, google-cloud-engineer, vercel-engineer, cloudflare-engineer, supabase-engineer)
skills/     7 skills (studex-coding-standards, mcp-server-builder, security-secrets-review,
            gcp-deploy, vercel-deploy, cloudflare-edge-runners, supabase-data)
template/   per-repo files: AGENTS.md, copilot-instructions.md, Deploy Guard CI,
            Copilot setup steps, PR + issue templates
scripts/    install.sh (one repo), rollout.sh (all repos via PRs), validate_vault.py
repos.txt   rollout list in waves
```

## Switch it on (≈20 min, one time)

1. **Copilot plan** — Copilot Pro+ / Business / Enterprise with the cloud agent enabled (github.com/settings/copilot).
2. **Team everywhere without touching each repo** — create a **private** repo named `.github-private` and copy `agents/` into its root `agents/` folder:
   - `StudEX/.github-private` → agents available in every StudEX org repo (documented GitHub feature).
   - `TumeloRamaphosa/.github-private` → same for your personal repos (works per community reports; per-repo install below is the guaranteed path).
3. **Skills + Deploy Guard per repo** — skills live in each repo's `.github/skills/`, so roll them out:
   ```bash
   gh auth login
   scripts/rollout.sh            # dry run
   scripts/rollout.sh --apply    # one PR per repo in repos.txt (wave 1+2 = 46 repos)
   ```
4. **Personal skills on your machines** (Copilot CLI + Claude Code):
   ```bash
   mkdir -p ~/.copilot/skills ~/.claude/skills
   cp -R skills/* ~/.copilot/skills/ && cp -R skills/* ~/.claude/skills/
   ```
5. **Auto code review** — repo or org ruleset → "Automatically request Copilot code review".
6. **Protected `production` environment** in each deploying repo, with you as required reviewer.
7. **Lane hookups**
   - Google: Gemini Spark / Jules access on your Google account; GCP Workload Identity Federation for Actions (see `skills/gcp-deploy`).
   - Vercel: deploy `vercel-labs/eve-software-factory-template` (Foreman), connect GitHub, point its instructions at `AGENTS.md` + `.github/skills/`. Label issues `factory`.
   - Cloudflare: Workers Paid plan + sandbox runner Worker (see `skills/cloudflare-edge-runners`).
   - Supabase: `npx skills add supabase/agent-skills`; Supabase MCP in Copilot repo settings.

## Using the team

Open an issue with the **Agent task** template → assign to **Copilot** → choose the agent. Copilot opens a PR, Deploy Guard runs, `reviewer` reviews, you approve and merge.

## Backups

GitHub is primary. `vault-backup.yml` validates the vault and then:
- **Gitea** push-mirror — set repo vars `GITEA_URL`, `GITEA_REPO`, `GITEA_USER` and secret `GITEA_TOKEN`. (Or create a pull mirror from the Gitea side: New Migration → GitHub → "This repository will be a mirror".)
- **Google Drive** copy via rclone — put the vault folder in a **Shared Drive** (service accounts have no My Drive storage), add the service account as a Content manager, then set secret `GDRIVE_SERVICE_ACCOUNT_JSON` and vars `GDRIVE_SHARED_DRIVE_ID` + `GDRIVE_VAULT_FOLDER_ID`.

Each target skips cleanly until configured.

## Adding a skill

`skills/<kebab-name>/SKILL.md` with `name` (= folder) and `description` frontmatter → PR → `python3 scripts/validate_vault.py` → merge → `scripts/rollout.sh --apply` refreshes every repo.
