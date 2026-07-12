# app-starter-skills

Skills for spinning up new apps, and for fixing existing ones, without
re-explaining your whole setup every time. Ships three skills for Claude Code:
`nextjs-app`, `flutter-app`, and `fastapi-app`.

Each skill works in two modes:

- **New app:** asks a short intake (project brief, app type, visibility, deploy
  target), checks the live latest package versions from the real registry, and
  scaffolds a project with a consistent structure, current dependencies, and a
  git and CI workflow already wired up.
- **Existing app:** audits an already-built codebase against the same standard
  (security, correctness, deprecated APIs, architecture, workflow), produces a
  gap report, and then retrofits fixes incrementally without breaking the app.

## Why

Starting a new project meant repeating the same instructions each time: use the
latest packages, avoid deprecated APIs, trust the real current date over the
model's stale training data, follow my folder structure, set up the branch model.
These skills carry all of that so you type one command instead. And once an app
exists, the same standard is the yardstick for cleaning it up.

The freshness problem is handled directly. Every skill runs a `check-latest.sh`
that queries npm, pub.dev, or PyPI for current stable versions at scaffold time,
and each skill tells the model to pull current framework docs before writing
code. Pinned versions come from the live registry, not from memory.

## What a skill is

A skill is a folder with a `SKILL.md` file (a short description plus
instructions) and optional supporting files. The model loads one automatically
when your task matches its description, or you invoke it by name. No server, no
build step. Just markdown and a couple of shell scripts.

## Install (Claude Code)

Add this repo as a plugin marketplace, then install the plugin:

```
/plugin marketplace add aneebbaig/app-starter-skills
/plugin install app-starter@app-starter-skills
```

Or clone the skills straight into your personal skills folder:

```
git clone https://github.com/aneebbaig/app-starter-skills.git
cp -R app-starter-skills/plugins/app-starter/skills/* ~/.claude/skills/
```

## Use

Start Claude Code and say what you want, or invoke the skill by name:

```
/nextjs-app
/flutter-app
/fastapi-app
```

In an empty directory the skill runs the new-app intake and scaffolds. Inside
an existing project it switches to audit-and-retrofit mode: report first, fix
after you approve.

### What triggers a skill

Claude Code activates a skill when your request matches its description. You do
not need the exact name. Any of these phrasings will pull in the right skill:

- New app: "new Next.js app", "scaffold a Flutter project", "start a Python
  backend", "set up a SaaS dashboard", "new landing page".
- Existing app: "audit this app", "review my codebase", "fix this project",
  "clean up this repo", "refactor to a better structure", "modernize this
  app", "upgrade the dependencies", "remove deprecated APIs", "harden this
  backend", "bring this app up to standard".

You can always force one by typing its name as a command: `/nextjs-app`,
`/flutter-app`, `/fastapi-app`.

## The skills

| Skill | Stack |
|---|---|
| `nextjs-app` | Next.js App Router, TypeScript, Prisma + Postgres, better-auth, Tailwind with shadcn or Mantine. Private, open-source, or both. |
| `flutter-app` | Flutter with FVM-pinned SDK, clean architecture, Riverpod or bloc, an Either/Failure error model, Play Store release setup. |
| `fastapi-app` | FastAPI with async SQLAlchemy 2.0, asyncpg, Alembic, Pydantic v2, JWT auth, Docker plus Postgres. |

Shared house rules (version freshness, mode detection and intake, the
existing-app audit workflow, git and CI, security hardening, writing style)
live in `plugins/app-starter/skills/shared/` and are read by every skill.

## Other agents

The same playbooks work outside Claude Code. See `AGENTS.md`. Point your agent
at the relevant `SKILL.md` and its `references/` folder.

## Customize

These defaults reflect one developer's stack. Fork it and edit the `references/`
files to match yours. The `SKILL.md` files stay small; the detail lives in
`references/` and `shared/`, which is where you make it your own.

## License

MIT. See `LICENSE`.
