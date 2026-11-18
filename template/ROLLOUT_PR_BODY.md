## What

Installs the **Studex Deployment Team**, led by GitHub Copilot, from [TumeloRamaphosa/Deployment-team](https://github.com/TumeloRamaphosa/Deployment-team).

Team: (1) GitHub Copilot — lead, (2) Google Gemini Spark — GCP lane, (3) Vercel Foreman — Vercel lane, (4) Cloudflare runners — edge/CI lane, (5) Supabase team — data lane.

- `.github/agents/` — `lead-engineer`, `architect`, `reviewer`, `release-engineer`, `security-officer`, `google-cloud-engineer`, `vercel-engineer`, `cloudflare-engineer`, `supabase-engineer`
- `.github/skills/` — `studex-coding-standards`, `mcp-server-builder`, `security-secrets-review`, `gcp-deploy`, `vercel-deploy`, `cloudflare-edge-runners`, `supabase-data`
- `.github/workflows/deploy-guard.yml` — gitleaks + lint/tests/build on every PR (free, open source)
- `.github/workflows/copilot-setup-steps.yml` — the environment Copilot cloud agent works in
- `AGENTS.md`, `copilot-instructions.md`, PR + issue templates (only added where missing)
- `.gitignore` — secret file patterns

## Before merging

- Fill in the **Repo-specific notes** in `AGENTS.md` (install / test / run / deploy).
- Check the Deploy Guard run. Red on an old repo usually means real lint or secret findings — fix them or leave the PR open.

## Rollback

Revert this PR. Nothing here deploys or changes runtime code.
