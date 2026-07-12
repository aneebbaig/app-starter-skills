# app-starter-skills

Claude Code skills that hold a full dev setup for three stacks, so you don't
have to re-explain it every session. Ships three skills: `nextjs-app`,
`flutter-app`, and `fastapi-app`.

Each skill works in two modes and picks the right one on its own:

- **New app**: short questionnaire, then a full scaffold with current
  dependencies, clean structure, auth, hardening, git workflow, and CI.
- **Existing app**: audits an already-built codebase against the same
  standard, hands you a gap report, and then fixes what you approve,
  incrementally and without breaking the app.

## Quick start

```
/plugin marketplace add aneebbaig/app-starter-skills
/plugin install app-starter@app-starter-skills
```

Then, in an empty directory:

```
> create a new flutter app for tracking gym workouts
```

Or inside an existing project:

```
> audit this app and bring it up to standard
```

That's it. The skill asks one batch of questions and goes.

## What you get on a new app

All three skills follow the same playbook:

1. **A short intake.** One batch of questions, each with a default already
   picked: project brief, app type (internal tool, SaaS, marketing site,
   mobile backend), open source or private, scale, deploy target. Reply
   "defaults" and it gets on with it. Stack choices (database, auth flavor,
   UI kit, state management) only come up when the app type doesn't already
   settle them.
2. **Live versions, not remembered ones.** A `check-latest.sh` script asks the
   real registry (npm, pub.dev, PyPI) at scaffold time and pins what it
   reports. The model is not allowed to use version numbers from memory, and
   has to pull current framework docs before writing framework code, so
   deprecated APIs from stale training data don't sneak in.
3. **A clean, layered structure.** Feature-first folders, thin route handlers,
   data access isolated behind repositories, no god files (a hard ~300-400
   line ceiling), no god functions (~50 lines), no magic strings or numbers.
4. **Security hardening by default.** No secrets in the client or the repo,
   `.env.example` from day one, generic production errors, brute-force
   lockout, no default credentials, TOTP 2FA support, debug surfaces off in
   prod. Backend is always the security boundary, never the client.
5. **Git and CI wired up.** Conventional commits, feature-branch workflow, a
   CI quality gate (lint, typecheck, tests, production build), auto-merge on
   green, optional release-please automation.
6. **A done gate.** Before the skill declares the job finished, it must run
   the full checklist (gates green, versions live, nothing hardcoded, no
   secrets committed) and show you the real command output.

### Per stack

| Skill | Defaults | Variants you can pick |
|---|---|---|
| `nextjs-app` | App Router, TypeScript strict, Prisma + Postgres, better-auth (with 2FA and rate limiting), Tailwind + shadcn/ui, pnpm, Vercel | different DB or none, Clerk or no auth, Mantine or plain Tailwind, npm, self-host Docker |
| `flutter-app` | FVM-pinned SDK, clean architecture (feature-first, use cases, repository and datasource interfaces + impls), Riverpod, Either/Failure error model, Play Store release with release-please | bloc instead of Riverpod (with its own best-practices playbook), Drift or Isar local data, BYOK LLM shape or custom backend, App Store |
| `fastapi-app` | Async SQLAlchemy 2.0 + asyncpg, Alembic, Pydantic v2 settings, JWT (PyJWT), layered routers/services/repositories, uv, Docker + Postgres | Google OAuth or API-key auth, pip instead of uv, SQLAdmin admin UI, Vercel serverless |

## What you get on an existing app

Point the skill at a codebase you already have (yours or inherited) and it
switches to audit mode:

1. **Intake**: what is the goal (audit only, audit then fix, or fix one named
   thing), what hurts, are breaking changes allowed, is the app live.
2. **Recon, read-only**: maps the structure, diffs installed versions against
   current stable, runs your existing lint/tests/build for a baseline.
3. **Gap report** before a single line changes, grouped by severity: security
   first (committed secrets, missing auth, default credentials, verbose prod
   errors), then correctness, deprecated APIs (each with its current
   replacement from live docs), architecture (god files, layer violations,
   hardcoded config), and workflow (CI, git hygiene). Every finding comes
   with file:line, why it matters, the concrete fix, and whether it breaks
   anything.
4. **Incremental retrofit** of what you approve: one concern per PR, tests
   pinned before refactors, majors upgraded one at a time via the official
   migration guides, additive-first schema changes on live apps. Never a
   big-bang rewrite.

## Open source support built in

Answer "open source" in the intake and the skill ships everything a public
repo needs: MIT LICENSE, stranger-facing README, CONTRIBUTING,
CODE_OF_CONDUCT, SECURITY policy, issue and PR templates, CHANGELOG via
release-please, and a working `.env.example` so anyone can run it.

There is also a strict rule the whole way through: nothing in the published
repo may reference an AI or read like one wrote it. No AI-tool files, no
co-author trailers, no em dashes or curly quotes. Enforced with actual scan
commands over the working tree and the full git history, plus a CI leak-guard
job that fails the build if a forbidden term ever lands. A private repo gets
the same code with a leaner docs set.

## What triggers a skill

Claude Code loads a skill when your request matches its description; the
exact name is never required. Examples that work:

- New app: "new Next.js app", "scaffold a Flutter project", "start a Python
  backend", "set up a SaaS dashboard", "new landing page".
- Existing app: "audit this app", "review my codebase", "fix this project",
  "clean up this repo", "refactor to a better structure", "modernize this
  app", "upgrade the dependencies", "remove deprecated APIs", "harden this
  backend", "bring this app up to standard".

Force one explicitly with `/nextjs-app`, `/flutter-app`, or `/fastapi-app`.

## How it is organized

```
plugins/app-starter/skills/
  shared/               rules every skill reads
    house-rules.md        version freshness, no god code, the done gate
    intake.md             mode detection + the questionnaire
    existing-app.md       the audit and retrofit workflow
    hardening.md          security defaults for every stack
    git-and-ci.md         branch model, conventional commits, leak guard
    no-ai-attribution.md  the human-written rule and its scan commands
    docs-and-context.md   live docs policy + optional local AI tooling
    open-source-docs.md   what a public repo must ship
  nextjs-app/  flutter-app/  fastapi-app/
    SKILL.md            the workflow (short)
    references/         the detail: stack, structure, best practices, gates
    scripts/check-latest.sh   live registry version check
```

`SKILL.md` files stay small; the opinions live in `references/` and
`shared/`. The split keeps the skill cheap to load and makes the whole thing
easy to fork and edit.

## Customize it

These defaults are one developer's stack. To make them yours:

1. Fork the repo.
2. Edit the `references/` files (stack choices, folder layout, best
   practices) and `shared/` files (git workflow, hardening posture, intake
   questions) to match how you build.
3. Add or remove package names in each `scripts/check-latest.sh`.
4. Install your fork the same way: `/plugin marketplace add <you>/<fork>`.

One rule if you edit: never write a version number into a skill or reference
file. The skills read versions from the live registry at run time; hardcoded
numbers rot. CI here also rejects smart punctuation, matching the standard
the skills enforce on their output.

## Manual install (no plugin system)

```
git clone https://github.com/aneebbaig/app-starter-skills.git
cp -R app-starter-skills/plugins/app-starter/skills/* ~/.claude/skills/
```

## Other agents (Cursor, Codex, ...)

The playbooks are plain markdown and work with any agent that can read files.
See `AGENTS.md` for the reading order; point your agent at the relevant
`SKILL.md` and its `references/` folder.

## Contributing

PRs welcome; see `CONTRIBUTING.md` for the workflow (conventional commits,
release-please versioning) and the style rules. Security reports: see
`SECURITY.md`.

## License

MIT. See `LICENSE`.
