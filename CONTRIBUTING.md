# Contributing

Thanks for looking. This repo holds bootstrap skills for Claude Code. The skills
scaffold new Next.js, Flutter, and FastAPI apps with current packages and a
consistent structure.

## Repo layout

```
.claude-plugin/marketplace.json     marketplace manifest (makes it installable)
plugins/app-starter/
  .claude-plugin/plugin.json         plugin manifest
  skills/
    shared/                          house rules read by every skill
    nextjs-app/  flutter-app/  fastapi-app/
      SKILL.md                       short: description + workflow
      references/                    the detail (stack, structure, gates)
      scripts/check-latest.sh        live version check
AGENTS.md                            entry point for non-Claude agents
```

Keep `SKILL.md` files short. Put detail in `references/`. That is the part you
edit to make the skills match your own stack.

## The freshness rule (important)

Never hardcode a package version anywhere. Not in a `SKILL.md`, not in a
`references/*.md`, not in a comment. Versions go stale the day you write them.

The skills work like this at runtime:

1. Read the injected current date. That is "now".
2. Run `scripts/check-latest.sh`, which queries the live registry (npm, pub.dev,
   PyPI) as of now.
3. Pin what the registry reports, and confirm framework APIs against current docs
   before writing code.

If you add a package to a stack, add its NAME to the relevant `check-latest.sh`
and describe it by name in `references/stack.md`. Do not write a version number.
CI does not let smart punctuation through, and reviewers reject hardcoded
versions.

## Making a change

1. Branch from `main` (`feat/...`, `fix/...`, `docs/...`).
2. Edit the skill or reference file. Keep the writing plain (see Style).
3. Commit with Conventional Commits: `feat:`, `fix:`, `chore:`, `docs:`,
   `refactor:`, `ci:`. The subject drives the version bump.
4. Open a PR into `main`. CI runs. Merge when green (auto-merge is enabled).

## Versioning and releases

Versioning is semver, managed by release-please from your commit messages:

- `fix:` bumps patch. `feat:` bumps minor. `feat!:` or a `BREAKING CHANGE:`
  footer bumps major.
- On merge to `main`, release-please opens or updates a release PR with the new
  version and CHANGELOG. Merging that PR tags the release and bumps the version
  in `plugin.json`, `marketplace.json`, and `version.txt`.
- Do not edit versions by hand. Let release-please do it.

What a version bump means here: minor for a new skill or a new convention, patch
for a doc fix or a script tweak, major when a change would alter how existing
projects get scaffolded in a breaking way.

## When frameworks or APIs change

Most of the time you do nothing. The skills check versions and docs live at
scaffold time, so a new Next.js or Flutter or FastAPI release is picked up
automatically without a code change here.

Edit a skill only when:

- your own conventions change (you drop Prisma, you move off Riverpod codegen),
- a framework ships a breaking change that needs a new default or a new pin note
  (add the note to `references/stack.md` by name, still no version number), or
- the Claude Code plugin or skill format changes (watch `plugin.json` and
  `marketplace.json`; the skill body is plain markdown and rarely affected).

## Style

The output apps must read as human-written, and so must this repo. Plain ASCII
only: no em or en dashes, no curly quotes, no ellipsis character. No AI-cadence
prose. CI fails the build if smart punctuation appears. See
`plugins/app-starter/skills/shared/no-ai-attribution.md`.
