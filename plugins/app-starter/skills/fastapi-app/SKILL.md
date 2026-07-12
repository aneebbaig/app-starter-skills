---
name: fastapi-app
description: Bootstrap a new FastAPI backend, or audit and retrofit an existing one, with async SQLAlchemy 2.0, asyncpg, Alembic, Pydantic v2, and no deprecated APIs. Use when the user wants to start, scaffold, or set up a new FastAPI service, a Python REST API, an async backend, or asks to "create a new fastapi app" or "new python backend". ALSO use on an existing FastAPI or Python API codebase when the user asks to audit, review, fix, clean up, refactor, modernize, upgrade, harden, or "bring up to standard" the service, migrate off SQLAlchemy 1.x or Pydantic v1 patterns, remove deprecated APIs, or improve the structure. Handles JWT auth, layered app structure, Docker + Postgres, and Vercel or container deploy.
---

# fastapi-app

Build or fix a FastAPI backend the way this owner builds them: async SQLAlchemy
2.0 with asyncpg, Alembic migrations, Pydantic v2 settings, a layered structure
(routers, services, models, schemas), JWT auth, and the house git and CI
workflow. Deployable to a container or Vercel.

First read the shared rules (they override anything you remember):
`../shared/house-rules.md`, `../shared/intake.md`,
`../shared/no-ai-attribution.md`, `../shared/git-and-ci.md`,
`../shared/docs-and-context.md`, `../shared/hardening.md`, and (for public
repos) `../shared/open-source-docs.md`.

## Step 0. Detect the mode, run the intake (hard stop)

Follow `../shared/intake.md` exactly: detect new-app vs existing-app mode from
the directory and the user's words, then ask the matching intake batch. Do not
run any scaffolding or editing command until it is answered.

**Existing-app mode:** skip to `../shared/existing-app.md` and follow it,
using this skill's `references/` as the standard to audit against. Steps 1-5
below are for new-app mode only.

**New-app mode:** the intake covers brief, app type, visibility, scale, and
deploy target. The only stack variants left to settle, each with a default the
app type usually decides (ask ONLY the ones the answers leave ambiguous, in
the same batch):

1. Auth: JWT via PyJWT (default), OAuth (Google), API-key, or none yet.
   better-auth has no Python runtime; PyJWT is the FastAPI standard.
2. Database: Postgres via async SQLAlchemy + asyncpg (default), or none yet.
3. Dependency tooling: `uv` (default, fast) or `pip` + `requirements.txt`.
4. Admin UI: SQLAdmin, or none (default: none).

If the user already answered something in their prompt, do not re-ask.

## Step 1. Verify environment and current versions

- Check Python (`python3 --version`, want a current supported 3.x).
- Run `scripts/check-latest.sh` for current stable versions from PyPI. Pin those,
  not versions from memory (`../shared/house-rules.md` rule 2).
- Pull current FastAPI, SQLAlchemy 2.0, and Pydantic v2 docs via Context7 before
  writing code (`../shared/docs-and-context.md`). SQLAlchemy 2.0 async and
  Pydantic v2 both broke v1 patterns; do not write v1-era code from memory.

## Step 2. Scaffold the project

Create a virtualenv and the layout from `references/structure.md`. With `uv`:

```
uv init <name> && cd <name>
uv add fastapi "uvicorn[standard]" "sqlalchemy[asyncio]" asyncpg alembic \
       pydantic-settings pyjwt httpx python-multipart
uv add --dev ruff pytest pytest-asyncio
```

With pip, install the same set and freeze into `requirements.txt`. Let the tool
resolve current versions; do not force numbers you remember.

## Step 3. Apply structure and conventions

- Layered app structure, async DB session, dependency-injected DB, settings, JWT
  auth: `references/structure.md`.
- Best practices, scalable domain-modular architecture, and nothing hardcoded:
  `references/best-practices.md`.
- Dependency set and version-boundary notes: `references/stack.md`.
- Production hardening (docs and schema disabled or gated in prod, generic error
  bodies, debug off, CORS locked): `../shared/hardening.md`.
- The no-god-code rule and layer separation: `../shared/house-rules.md` rule 8.

## Step 4. Git, CI, docs, security

- Git branch model, conventional commits, auto-merge: `../shared/git-and-ci.md`.
- CI (ruff + pytest), Docker, migrations: `references/quality-gates.md`.
- Gitignore `.env*` and any service-account JSON. Provide `.env.example`.
  Settings load from env through `pydantic-settings`, never hardcoded.
- Add `docs/` and a README. For a public repo, ship the full open-source docs set
  per `../shared/open-source-docs.md` and run the open-source hard gate in
  `../shared/no-ai-attribution.md` before the first push.

## Step 5. Verify before declaring done

Run the gates in `references/quality-gates.md`: `ruff check`, `pytest`, the app
imports and starts, `/health` responds, and Alembic can generate a revision.
Then run the done gate in `../shared/house-rules.md` rule 10 and echo each
answer. Report real results.
