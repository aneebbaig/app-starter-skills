# Next.js variants: private, open-source, private + open-source

Ask the visibility question first (SKILL step 0), then set the repo up for that
variant. The code is the same; what changes is licensing, README tone, secret
posture, and repo split.

## Private (default product repo)

- `gh repo create <name> --private`.
- README can be terse and internal: what it is, how to run, env keys, deploy.
- No LICENSE required. If you add one, use a proprietary "all rights reserved"
  note, not MIT.
- Secrets in Vercel env and GitHub Actions secrets. `.env*` gitignored.
- Add `CONTRIBUTING.md` only if teammates will work in it.

## Open-source (public)

- `gh repo create <name> --public`.
- Add `LICENSE` (MIT unless the owner says otherwise), `README.md` written for
  strangers (badges, quickstart, screenshots), `CONTRIBUTING.md`,
  `CODE_OF_CONDUCT.md`, and `SECURITY.md`.
- Add `.github/ISSUE_TEMPLATE/` and a PR template.
- Absolutely no secrets, no real credentials, no internal URLs in history. If any
  secret ever touched a commit, rotate it and scrub history before going public.
- Ship a working `.env.example` and a seed path so a stranger can run it.

## Private + open-source (product + public core)

Three shapes exist. Ask which one actually applies before picking a repo
structure. The wrong pick here is the single biggest source of ongoing
maintenance pain in a scaffolded app: two repos to sync forever, when one would
have done.

1. **Public library/SDK + private app that depends on it.** Two repos, because
   the library genuinely has its own release cadence and other consumers.
2. **Monorepo with a shareable core** (owner already works in `apps/web`,
   `apps/mobile`). Public repo holds the shareable core; the private product
   consumes it. Keep proprietary code out of the public app folder.
3. **One product, two identities: a generic public template AND the owner's
   own branded deployment.** This is the common case for "I built a real app
   for myself, want to open-source it too, but don't want the public repo to
   say my name/brand." Default to a **single public repo**, not two. Branding
   (app name, package ID / bundle ID, API base URL) lives entirely in
   environment variables and CI repo variables, never in code. The owner's own
   deployment reads those variables from Vercel's dashboard / GitHub repo
   settings; a stranger who forks the repo gets sensible generic defaults for
   free with zero code changes. A second private repo is warranted here only
   if the owner has private notes, infra config, or deploy secrets they want
   entirely out of git history (not just out of the diff) - and even then,
   prefer gitignoring those files (`CLAUDE.md`, deploy notes, `.vercel/`) over
   forking the whole repo. See `../shared/git-and-ci.md` for the CI-side leak
   guard that backstops this.

   Ask: "does this need to be BOTH a thing others can self-host under their own
   name AND a specific thing you personally run?" If no, it is shape 3 with the
   two-identity option turned off, i.e. just a plain open-source repo (see
   above) deployed directly. If yes, single public repo with env-driven
   branding is still the default; only split into two repos if the owner
   explicitly wants the personal deployment's existence itself kept unlisted
   (see "Keeping a personal deployment unlisted" below).

Draw a hard line regardless of shape: anything with secrets, paid-feature
gating, or customer data stays private. The public side gets an MIT LICENSE and
a stranger-facing README; the private side stays terse and internal.

### Keeping a personal deployment unlisted

A public repo does not force a public deployment. Nothing requires linking a
live URL from the README, GitHub profile, or anywhere else - most open-source
repos never mention who runs a production instance or where. Two things to get
right if the owner wants zero incidental traffic on their own instance:

- If deploying via Vercel's GitHub App integration, it posts deployment status
  and preview links directly on commits/PRs, which is enough to leak the URL to
  anyone browsing the public repo. Either deploy via `vercel deploy` from a
  script/Action instead of the auto Git-connect, or turn on Vercel's
  **Deployment Protection** (password or platform-auth gate in front of the
  whole site) so a leaked URL still doesn't grant access.
- Deployment Protection is the actual traffic control; hiding the URL alone is
  security-through-obscurity and does not stop scanners. Combine both: don't
  link the URL, and gate it anyway.

In all cases the no-AI-attribution rule applies to every published file
(`../shared/no-ai-attribution.md`). A public repo is the worst place to leak an
AI-tool file or AI-cadence prose, so scan before the first push.
