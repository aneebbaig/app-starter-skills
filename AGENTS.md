# AGENTS.md

Cross-agent entry point for the app-starter playbooks. Works with any coding
agent that reads an `AGENTS.md` (Cursor, Codex, and others), not just Claude
Code.

These playbooks bootstrap new apps with current packages, no deprecated APIs, and
a consistent structure. The content lives as skills under
`plugins/app-starter/skills/`. To use them outside Claude Code, read the relevant
files directly.

## Pick the stack

- New Next.js web app: read
  `plugins/app-starter/skills/nextjs-app/SKILL.md` and everything in its
  `references/` folder.
- New Flutter mobile app: read
  `plugins/app-starter/skills/flutter-app/SKILL.md` and its `references/`.
- New FastAPI backend: read
  `plugins/app-starter/skills/fastapi-app/SKILL.md` and its `references/`.

## Always read the shared rules first

Before any stack-specific work, read every file in
`plugins/app-starter/skills/shared/`:

- `house-rules.md` version freshness, current date, no deprecated APIs.
- `no-ai-attribution.md` how the output repo must read as human-written.
- `git-and-ci.md` branch model, conventional commits, auto-merge on green CI.
- `docs-and-context.md` pulling current framework docs before writing code.

## Run the version check

Each skill has `scripts/check-latest.sh`. Run it before scaffolding to get
current stable versions from the live registry. Pin what it reports, not versions
from training data.
