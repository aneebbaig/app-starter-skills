# Intake: detect the mode, then ask the short questionnaire

Every skill starts here. First decide the MODE, then run the matching intake.
Never skip mode detection, and never run scaffolding commands in an existing
codebase.

## Mode detection (do this before asking anything)

Look at the working directory:

- Empty, or no project files for this stack -> **new-app mode**.
- Contains an app of this stack (package.json with `next`, a `pubspec.yaml`,
  a pyproject/requirements with `fastapi`) -> **existing-app mode**. Read
  `existing-app.md` and follow it. Do NOT scaffold, do NOT overwrite files,
  do NOT run a create/init CLI.
- Contains a project of a DIFFERENT stack -> stop and confirm with the user
  before touching anything.

If the user's words make the mode obvious ("new app" vs "audit / fix / clean
up / refactor / upgrade my app"), trust the words plus the directory, and only
ask when the two disagree.

## New-app intake (quick bootstrap, not an interrogation)

New apps bootstrap FAST. Everything is a smart default (structure, packages,
auth standard, hardening, latest versions via check-latest.sh). Ask ONE batch
of questions, each with a default pre-selected, then scaffold.

0. **Project brief** (no default). One paragraph: what the app does, main
   features, target users, hard constraints. If the user already gave one, do
   not re-ask. The brief drives naming, features, and the data model.
1. **App type** (default: internal-tool). Drives most other choices:
   - `internal-tool` / `admin-panel` -> single owner or RBAC, private, no signup.
   - `saas` -> multi-tenant, public signup, org/roles, billing-ready.
   - `marketing-site` / `portfolio` -> mostly static + a small admin panel.
   - `mobile-backend` -> API consumed by a Flutter client. If the backend is
     Node/Next.js, use better-auth with the bearer plugin; if it is FastAPI,
     use PyJWT (better-auth has no Python runtime).
2. **Open source or private?** (default: private). Gates LICENSE, CONTRIBUTING,
   docs, and CI per house-rules.md. Decide this FIRST among the artifacts.
3. **Rough scale** (default: small, <1k users). Ask only if `saas`; picks
   caching, connection pooling, and queue defaults. Skip for other types.
4. **Deploy target** (default per stack: Vercel + Neon for Next.js, Docker for
   FastAPI, store release for Flutter). Ask only if the type implies something
   else.
5. **Local Claude tooling?** (default: skip). Offer graphify (knowledge graph
   of the codebase, queried instead of re-reading files) and the caveman
   plugin (compressed responses, big token savings). See the "Local AI
   tooling" section of `docs-and-context.md`. Everything this sets up is
   LOCAL ONLY and gitignored; nothing AI-related is ever committed
   (`no-ai-attribution.md`).

Then, and only then, ask any stack-specific variant the app type leaves
genuinely ambiguous (each skill lists its variants and their defaults in its
SKILL.md). Do NOT ask about packages, folder structure, lint config, auth
mechanism, or versions; those are fixed defaults from the standard. If the
user gave the app type up front, ask nothing else unless a choice is genuinely
ambiguous.

Batch every question into ONE message. Accepting the default on everything
must be possible with a single "defaults" reply.

## Existing-app intake

For an existing codebase the questions change. Ask this batch (defaults
pre-selected), then follow `existing-app.md`:

1. **Goal** (default: audit-then-fix). One of:
   - `audit-only` -> produce the gap report, change nothing.
   - `audit-then-fix` -> report first, then fix what the user approves.
   - `fix-specific` -> the user already knows what hurts; audit only the
     named area, then fix it.
2. **What hurts most?** (free text, optional). Bugs, slow builds, deprecated
   warnings, messy structure, security worries. Focuses the audit.
3. **Breaking changes allowed?** (default: no). May we bump major versions,
   change the DB schema, change auth, or restructure folders? "No" limits
   fixes to non-breaking ones and flags the rest as proposals.
4. **Is it live?** (default: yes, treat as production). A production app gets
   migration-safe, incremental fixes; a pre-launch app can take bigger moves.
5. **Open source or private?** Same gate as the new-app intake; an existing
   public repo also gets the no-ai-attribution history scan.
6. **Local Claude tooling?** (default: skip). Same offer as new-app question 5;
   graphify pays off most on a big existing codebase, since the audit can
   query the graph instead of re-reading everything.

Never begin editing an existing app before questions 1 and 3 are answered.
That is a hard stop.
