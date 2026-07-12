# Existing app: audit and retrofit workflow

How to bring an already-built codebase up to the house standard. The same
references and rules apply as for a new app; what changes is HOW you apply
them. The prime directive: **never break a working app to make it prettier.**

## Hard rules (non-negotiable)

- NEVER scaffold, `create`, or `init` inside an existing project.
- NEVER big-bang rewrite. Fixes land as small, reviewable changes, one concern
  per branch/PR, each leaving the app green.
- NEVER delete or replace code you have not read and understood.
- NEVER change DB schema, auth, or public API shape when the user answered
  "no breaking changes" in intake; propose those separately instead.
- ALWAYS run the project's existing tests/build BEFORE the first change to
  establish a baseline. If there is no baseline (no tests, broken build), say
  so and get the build green first; that is fix number one.
- ALWAYS re-run the stack's quality gates after every change set.

## Phase 1: Recon (read-only)

Map the app before judging it:

1. Detect stack and versions: read package.json / pubspec.yaml / pyproject,
   the lockfile, and the framework config. Record installed versions.
2. Run `scripts/check-latest.sh` for the stack and diff installed vs current
   stable. Note every major-version gap.
3. Map the structure: folder layout, layering, where data access, business
   logic, and UI live. Compare against the stack's `references/structure.md`
   or `architecture.md`.
4. Run the existing lint/typecheck/test/build commands and record real output.
5. Pull current docs (Context7 or vendored docs) for the installed AND target
   framework versions before judging any API usage as deprecated. Judge
   against current docs, not memory.

## Phase 2: Gap report (still read-only)

Produce a written report, grouped by severity, before changing anything:

1. **Security** (fix first, always in scope): committed secrets, secrets in
   client bundles or binaries, missing auth on privileged routes, open
   registration on single-owner apps, default credentials, missing lockout,
   verbose prod errors, debug surfaces in prod, wildcard CORS. Judge against
   `hardening.md`.
2. **Correctness**: broken build, failing tests, runtime errors, unawaited
   async, race conditions.
3. **Deprecated and outdated**: deprecated API usage, packages more than one
   major behind, EOL runtimes. For each, name the current replacement from
   the live docs, not from memory.
4. **Architecture**: god files and god functions (house-rules.md), layer
   violations (UI running queries, business logic in widgets/handlers),
   missing structure vs the reference layout, hardcoded config that belongs
   in env or constants.
5. **Workflow**: missing or weak CI, no quality gates, secrets handling, git
   hygiene, missing docs. For a public repo, run the `no-ai-attribution.md`
   hard gate over tree AND history and report violations.

For every finding give: file:line, what is wrong, why it matters, the concrete
fix, and whether the fix is breaking. Do not pad the report; if an area is
fine, say it is fine in one line.

Present the report and STOP if the goal is `audit-only`. Otherwise get the
user's pick of what to fix (default order: security -> correctness ->
deprecated -> architecture -> workflow).

## Phase 3: Retrofit (incremental)

- Work in the approved order. One concern per change set: "move queries out
  of components" is one PR, "upgrade Prisma major" is another.
- Before refactoring an area with no test coverage, add a characterization
  test (or at minimum a manual smoke script) so behavior is pinned first.
- Version upgrades go one major at a time, following the official migration
  guide for each step (fetch it live). Run the full gates between steps.
- When restructuring folders, move files with `git mv` in dedicated commits
  so history and review stay readable; do not mix moves with logic edits.
- Migration safety for live apps: schema changes are additive first
  (expand -> migrate data -> contract), auth changes keep existing sessions
  or force re-login deliberately and say so, env var renames keep the old
  name working for one release.
- Anything the user disallowed as breaking gets written up as a proposal at
  the end, not silently done.

## Phase 4: Done gate

Same bar as a new app. All the stack's quality gates green, hardening rules
applied, no new god files, nothing hardcoded that the standard says must be
env or constants, and (public repos) the no-ai-attribution scan clean. Report
real command output, including failures. An audit that changed code and did
not re-run the gates is not done.
