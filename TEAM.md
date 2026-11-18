# Studex Deployment Team — roster & routing

Tumelo Ramaphosa is the only human approver. Nothing merges or reaches production without him.

| # | Member | Lane | Native platform agent | Copilot persona (`.github/agents/`) | Skill |
|---|---|---|---|---|---|
| 1 | **GitHub Copilot** | **Lead engineer** — plans, code, PRs, review, security | Copilot cloud agent + code review | `lead-engineer`, `architect`, `reviewer`, `security-officer` | `studex-coding-standards`, `security-secrets-review`, `mcp-server-builder` |
| 2 | **Google — Gemini Spark** | Google Cloud: Cloud Run, Firestore, Secret Manager, Workspace/Drive | Gemini Spark (24/7 agent), Jules, Gemini CLI | `google-cloud-engineer` | `gcp-deploy` |
| 3 | **Vercel — Foreman** | Front-ends & sites on Vercel; issue → reviewed draft PR factory | Foreman (eve software factory template) | `vercel-engineer` | `vercel-deploy` |
| 4 | **Cloudflare runners** | Edge (Workers, DNS, R2) + ephemeral CI runners for agents | Cloudflare Sandbox runners / Cloudflare CI | `cloudflare-engineer` | `cloudflare-edge-runners` |
| 5 | **Supabase team** | Postgres schema, migrations, RLS, edge functions, auth | Supabase MCP + Supabase agent skills | `supabase-engineer` | `supabase-data` |

The `release-engineer` persona is Copilot's dispatcher: it owns the Deploy Guard and hands each deploy to the right lane.

## Routing (labels)

| Label on an issue | Who picks it up |
|---|---|
| `agent:lead-engineer` (default) | Assign to Copilot → choose `lead-engineer` |
| `agent:architect` / `agent:security-officer` / `agent:release-engineer` | Assign to Copilot → choose that agent |
| `lane:google` | Copilot `google-cloud-engineer`; Gemini Spark for long-running GCP ops |
| `lane:vercel` + `factory` | Foreman picks it up and opens a draft PR (Foreman triggers on the `factory` label) |
| `lane:cloudflare` | Copilot `cloudflare-engineer`; heavy CI jobs run on Cloudflare runners (`runs-on: [self-hosted, cloudflare]`) |
| `lane:supabase` | Copilot `supabase-engineer` |

One issue → one owner. If two lanes are needed, the `architect` splits it into one issue per lane, with `blocked-by #N` where order matters.

## Flow

```
Tumelo opens issue ──► lead-engineer triages ──► (big?) architect splits into lane issues
                                   │
                                   ▼
               lane agent builds ──► PR ──► Deploy Guard (CI) ──► reviewer (+ security-officer)
                                                               │
                                                               ▼
                                         Tumelo approves ──► lane deploys (protected env) ──► health check / rollback
```

## Free open-source fallbacks per lane

| Lane | Paid / managed | Popular free open-source alternative |
|---|---|---|
| Lead | GitHub Copilot | OpenHands, Aider, Cline, Continue, Qodo PR-Agent (reviews) |
| Google | Gemini Spark / Jules | Gemini CLI (Apache-2.0); Knative or Coolify instead of Cloud Run |
| Vercel | Vercel hosting | Foreman template itself is MIT; Coolify / Dokploy / Netlify-free for hosting |
| Cloudflare | Workers paid plan, Sandbox runners | actions-runner-controller (ARC) on k3s; plain GitHub-hosted runners |
| Supabase | Supabase Cloud | Self-hosted Supabase (Apache-2.0) or plain Postgres + PostgREST |
