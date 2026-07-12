# House rules (all stacks)

These rules apply to every app the starter skills scaffold AND to every
existing app they audit or retrofit (see `existing-app.md`). Read them before
writing any code. They exist because a model's training data is always older
than the packages you are about to install.

Rules 1-3 and 8 use MUST/NEVER language on purpose: they are gates, not
style preferences. Rule 10 is the checklist that enforces them at the end.

## 1. Trust the injected current date, not your training cutoff

Claude Code injects the real current date into the session. Believe it. Your
training cutoff is months behind it. Any statement like "the latest version is
X" from memory is a guess and is probably wrong. Confirm versions live (rule 2).

## 2. Latest stable packages, verified live (never hardcoded)

Order of operations, every time:

1. Read the injected current date (rule 1). That is "now".
2. As of that date, query the real registry for current stable versions by
   running the skill's `scripts/check-latest.sh` (npm, pub.dev, PyPI).
3. Pin what the script reports.

No version number is hardcoded anywhere in these skills. The `references/*.md`
files describe the stack by package NAME and never carry a pinned version,
because versions go stale the moment they are written. If you ever see a version
number in a reference file, treat it as a bug and ignore it in favor of the live
check. Pin what the registry says now, not what you remember.

- Prefer the latest STABLE release. Do not pull prereleases (alpha, beta, rc)
  unless the ecosystem norm requires it. When you use a prerelease, say why in
  one line.
- After install, run the project's own version print (`next --version`,
  `flutter --version`, `pip show fastapi`) and record the real installed
  versions in the project's docs.

## 3. No deprecated APIs, current best practices only

Deprecated code is the single most common failure when a model scaffolds with
stale memory. Defend against it:

- You MUST consult current docs through Context7 (see `docs-and-context.md`)
  for the framework before writing framework-specific code. Do this even for
  frameworks you think you know. APIs move.
- Heed every deprecation warning the tooling prints. NEVER silence one; fix it.
- When the installed major version differs from what you remember, assume the
  API changed and read the migration notes before writing code.
- The same applies to patterns, not just APIs: if the framework's current docs
  recommend a different idiom than the one you remember, use the current one.

## 4. Write like a human developer

The output repo must read as if a human wrote it. See `no-ai-attribution.md`
for the hard rules. In short: plain ASCII punctuation, no em or en dashes, no
curly quotes, no AI-cadence prose, and no reference to any AI tool anywhere in
the code, comments, docs, commits, or metadata.

## 5. Git, commits, and CI

Follow `git-and-ci.md`: conventional commits authored as a human, feature branch
into an integration branch, PR, and auto-merge on green CI. No AI co-author
trailers, ever.

## 6. Security defaults

- NEVER commit secrets. `.env*`, keystores, service-account JSON, and signing
  credentials are gitignored from the first commit.
- Provide a `.env.example` with keys and blank or placeholder values.
- Secrets live in the platform secret store (GitHub Actions secrets, Vercel env,
  platform keychain), never in the repo.

## 7. Ask the intake, then proceed

Every skill starts with mode detection and the short intake in `intake.md`
(new-app or existing-app). Ask that one batch, then build without further
hand-holding. Do not re-litigate settled choices or narrate options you will
not take, and do not invent extra questions the intake does not list.

## 8. No god functions, files, or architecture

Keep units small and single-purpose. This is a hard rule, not a preference.

- **Functions do one thing.** If a function needs "and"/"then" to describe it,
  split it. Rough ceiling ~50 lines; extract helpers past that.
- **No god files.** A file has one clear responsibility. Rough ceiling ~300-400
  lines; split by concern (a route != its validation != its data access).
  Barrel/util dumping grounds ("utils.ts" holding 40 unrelated helpers) are
  banned; group by domain.
- **No god objects/modules.** No single class/module that knows about
  everything. Depend on small interfaces, not one mega-service.
- **Layer separation.** UI != business logic != data access. A component must
  not run SQL; a route handler must not render.
- **Review check:** before finishing a change, if any function or file grew past
  the ceiling or took on a second responsibility, split it before committing.

## 9. Open source vs private drives license, docs, and CI

Ask up front (see `intake.md`) whether the app is open source or private; it
changes real artifacts:

- **Open source:** add a `LICENSE` (default MIT unless told otherwise),
  `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `SECURITY.md`, a public-facing
  `README` (what/why/quickstart/screenshots), and CI that runs on PRs from
  forks. No secrets or internal URLs anywhere in the repo.
- **Private:** no `LICENSE` needed (or a proprietary notice), leaner README
  (setup + deploy only), internal notes allowed. CI still runs, but assumes
  trusted contributors.

Never publish a repo as open source with a baked-in backend URL, key, or
internal doc. Decide open-vs-private FIRST; it gates what files get generated.

## 10. The done gate (run it, echo it, every time)

Before declaring any scaffold or retrofit done, run this checklist and state
each answer explicitly in your report. A "no" on any line means you are not
done; fix it or report the failure with real output.

1. Versions came from `check-latest.sh` output in THIS session, not memory.
2. Current framework docs were consulted before framework code was written.
3. The stack's quality gates (see `references/quality-gates.md`) all pass,
   with real command output shown.
4. No function or file violates rule 8 in code you wrote or touched.
5. No secret, `.env`, keystore, or service-account file is committed.
6. `hardening.md` rules for this stack are applied.
7. The output contains no AI reference, em/en dash, or curly punctuation
   (`no-ai-attribution.md`); for a public repo, the hard gate over tree and
   history is clean.
8. Everything claimed as done was actually run and observed, not assumed.
