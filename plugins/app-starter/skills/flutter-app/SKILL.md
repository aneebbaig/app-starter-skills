---
name: flutter-app
description: Bootstrap a new Flutter mobile app, or audit and retrofit an existing one, with clean architecture, Riverpod or bloc, FVM-pinned SDK, current packages, and no deprecated APIs. Use when the user wants to start, scaffold, or set up a new Flutter app, a cross-platform mobile app, an Android or iOS app in Dart, or asks to "create a new flutter app". ALSO use on an existing Flutter or Dart codebase when the user asks to audit, review, fix, clean up, refactor, modernize, upgrade, harden, or "bring up to standard" the app, fix analyzer issues, remove deprecated APIs, restructure to clean architecture, or migrate state management to Riverpod or bloc. Handles BYOK LLM apps, backend-backed apps, Play Store release setup, and clean-architecture feature structure.
---

# flutter-app

Build or fix a Flutter app the way this owner builds them: FVM-pinned SDK, clean
architecture (feature-first), Riverpod for state, an Either/Failure error model,
current stable packages, and the house git and CI workflow with release-please
and Play Store delivery.

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
release target. The only stack variants left to settle, each with a default
the app type usually decides (ask ONLY the ones the answers leave ambiguous,
in the same batch):

1. Backend: BYOK (each user supplies their own LLM key, no backend), a custom
   backend (Dio + JWT auth), or none yet. See `references/architecture.md`.
2. State management: Riverpod (default) or bloc (`flutter_bloc`). If Riverpod,
   also settle codegen (`@riverpod` + build_runner, default) vs hand-written
   providers. If bloc, follow `references/bloc-practices.md` for everything
   state-related; the clean architecture stays identical either way.
3. Local data: Drift, Isar, shared_preferences only, or none yet.
4. Auth: Google Sign-In, backend-driven, or none.
5. Release target: Play Store (default), App Store, or both.

If the user already answered something in their prompt, do not re-ask.

## Step 1. Pin the SDK with FVM and verify versions

- Use FVM so the SDK is pinned per project: `fvm use stable` (or a specific
  stable). Every command runs through `fvm flutter ...`.
- Run `fvm flutter --version` and record the real Flutter and Dart versions in
  the project docs.
- Run `scripts/check-latest.sh` for current stable package versions from pub.dev.
  Pin those, not versions from memory (`../shared/house-rules.md` rule 2).
- Pull current docs for Flutter, Riverpod, and any codegen packages via Context7
  before writing code (`../shared/docs-and-context.md`). Riverpod's provider
  syntax and codegen naming change between majors; confirm before writing.

## Step 2. Scaffold with the official CLI

```
fvm flutter create --org com.<owner>.<app> --platforms=android,ios <name>
```

Then add dependencies from `references/stack.md` and lay out the folders from
`references/architecture.md`.

## Step 3. Apply architecture and conventions

- Clean-architecture layers, feature structure, Either/Failure model, DI, and the
  non-negotiable conventions (use cases, datasource interface plus impl, custom
  widgets, extensions, central utils, constants for everything, zero hardcoding):
  `references/architecture.md`.
- Riverpod and Flutter do's and don'ts, and code smells to avoid:
  `references/best-practices.md`. If the state answer is bloc, use
  `references/bloc-practices.md` for all state-holder patterns instead of the
  Riverpod sections (the widget and code-smell sections still apply).
- Dependency set and pinning notes (some packages must be pinned to avoid
  analyzer conflicts): `references/stack.md`.
- Production hardening (obfuscated release builds, no baked-in secrets, no debug
  symbols in git): `../shared/hardening.md`.
- The no-god-code rule and layer separation: `../shared/house-rules.md` rule 8.

## Step 4. Git, CI, release, docs, security

- Git branch model, conventional commits, auto-merge, release-please:
  `../shared/git-and-ci.md`.
- CI (analyze + test), signing, and Play Store delivery:
  `references/quality-gates.md`.
- Gitignore signing keys, keystore, `google-services.json`, and `.env*`. Store
  them as CI secrets. Provide `.env.example`.
- Add `docs/` (git-workflow, architecture, release-process) and a README. For a
  public repo, ship the full open-source docs set per
  `../shared/open-source-docs.md` and run the open-source hard gate in
  `../shared/no-ai-attribution.md` before the first push.

## Step 5. Verify before declaring done

Run the gates in `references/quality-gates.md`: `fvm flutter analyze` must be
zero issues, `fvm flutter test` green, and the app must build and run. Then run
the done gate in `../shared/house-rules.md` rule 10 and echo each answer.
Report real results.
