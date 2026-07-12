# Git and CI (all stacks)

The same branch model and merge workflow across every app.

## Branch model

```
main       production. Deploys go from here. Protected.
develop    integration. Feature branches land here first. CI runs on PRs.
feature/*  daily work. Branch from develop, PR back to develop.
hotfix/*   critical prod fix. Branch from main, PR to main, back-merge to develop.
release/*  version bump when not using release-please. Branch from develop, PR to main.
```

For a small solo project you may start with just `main` + `develop`. Add
`staging` only when a real pre-prod environment exists.

## Conventional commits

`feat:`, `fix:`, `chore:`, `docs:`, `refactor:`, `test:`, `perf:`, `ci:`.
Subject in the imperative, under about 70 chars. Body only when the "why" is not
obvious from the subject. Authored as the human owner. No AI trailers (see
`no-ai-attribution.md`).

## Auto-merge on green CI

Do not poll-and-merge by hand. For each PR, enable GitHub auto-merge so it merges
itself the moment required checks pass:

```
gh pr merge <number> --squash --auto
```

Enable "Allow auto-merge" and "Automatically delete head branches" in repo
settings once, up front. Never bypass CI with `--admin` except for a
release-automation bot PR that CI cannot run on by design.

## CI baseline

A `build` job on every PR into `develop` and `main` that runs the stack's
quality gates (lint, typecheck, tests, and a production build). Branch protection
requires that job to pass before merge. See each skill's `quality-gates.md` for
the exact commands.

## Leak guard CI (public repos, and any repo with a public side)

`.gitignore` and a local habit are not a backstop by themselves; add a CI job
that scans every push to `main` and every PR for AI-tool references, so a leak
fails loudly in a place the owner cannot forget to check:

```yaml
name: Leak guard
on:
  push:
    branches: [main]
  pull_request:
jobs:
  scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Scan for forbidden strings
        run: |
          if grep -rIniE 'cla[u]de|anthrop[i]c|cop[i]lot|chat[g]pt|<owner-handle>' . \
               --exclude-dir=node_modules --exclude-dir=.git \
               --exclude='*.lock' --exclude='package-lock.json' \
               --exclude='pnpm-lock.yaml' --exclude='yarn.lock' \
               --exclude='guard.yml' --exclude='.gitignore'; then
            echo "::error::Forbidden term found. Remove before merging."
            exit 1
          fi
```

Replace `<owner-handle>` with the owner's real handle or brand terms they want
kept out of the public repo, or drop that alternative entirely. Do not ship
the literal placeholder.

Three gotchas that will bite otherwise:

- Exclude the workflow file itself (`guard.yml`) - the pattern source contains
  the literal string it is searching for.
- Exclude `.gitignore` - the entry that keeps `CLAUDE.md` out of the repo
  (`no-ai-attribution.md`) is itself a line containing the word "claude", so
  the guard will flag its own protection unless excluded. This is not
  theoretical: it happened on the first real use of this pattern.
- Exclude every lockfile flavor the stack uses (`package-lock.json`,
  `pnpm-lock.yaml`, `yarn.lock`, `*.lock`); registry metadata inside them can
  trip the scan with false positives.

## Release automation

Prefer release-please to manage version bumps and CHANGELOG from conventional
commits. It opens a release PR on pushes to `main`; merging it tags the release,
which triggers the deploy or publish workflow. Never hand-edit the version or
create tags manually when release-please is in use.
