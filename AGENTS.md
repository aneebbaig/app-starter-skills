# AGENTS.md

Cross-agent entry point for the app-starter playbooks. Works with any coding
agent that reads an `AGENTS.md` (Cursor, Codex, and others), not just Claude
Code.

These playbooks do two jobs: bootstrap NEW apps with current packages, no
deprecated APIs, and a consistent structure; and audit-and-retrofit EXISTING
apps to the same standard. The content lives as skills under
`plugins/app-starter/skills/`. To use them outside Claude Code, read the
relevant files directly.

## Pick the stack

- Next.js web app (new or existing): read
  `plugins/app-starter/skills/nextjs-app/SKILL.md` and everything in its
  `references/` folder.
- Flutter mobile app (new or existing): read
  `plugins/app-starter/skills/flutter-app/SKILL.md` and its `references/`.
- FastAPI backend (new or existing): read
  `plugins/app-starter/skills/fastapi-app/SKILL.md` and its `references/`.

## Always read the shared rules first

Before any stack-specific work, read every file in
`plugins/app-starter/skills/shared/`:

- `house-rules.md` version freshness, no deprecated APIs, no god code, the
  done gate.
- `intake.md` mode detection (new vs existing app) and the questionnaire.
- `existing-app.md` the audit and retrofit workflow for existing codebases.
- `no-ai-attribution.md` how the output repo must read as human-written, and
  the mechanical scans that enforce it.
- `git-and-ci.md` branch model, conventional commits, auto-merge on green CI,
  the leak-guard CI job.
- `docs-and-context.md` pulling current framework docs before writing code.
- `hardening.md` production hardening and auth rules for every stack.
- `open-source-docs.md` the docs a public repo must ship.

## Run the version check

Each skill has `scripts/check-latest.sh`. Run it before scaffolding or before
judging an existing app's dependencies. Pin what it reports, not versions from
training data.
