# Hardening: make the shipped app hard to reverse engineer

Every app these skills scaffold should be built so that a shipped artifact leaks
as little as possible: no secrets, no readable internals, no debug surface. Apply
the parts that fit the stack.

## Rules for all stacks

- No secrets in the client or in any shipped artifact. Keys, tokens, and DB
  credentials live only in the platform secret store or, for BYOK apps, in the
  user's own secure storage. A secret compiled into a binary or a browser bundle
  is a secret you have published.
- Ship production builds only. Debug builds carry symbols, assertions, and
  verbose logging that hand an attacker a map.
- Do not commit debug symbols, source maps, or mapping files. Gitignore them and
  keep them out of the published artifact. Archive them privately for crash
  symbolication.
- Errors shown to a client are generic. Full stack traces, framework versions,
  and internal paths stay in server logs, never in a response or a UI.
- Turn off any debug or introspection surface in production (debug flags, admin
  panels behind auth, verbose headers).

## Auth and user management (all stacks)

The default auth is `better-auth` for Next.js and Flutter clients (see the
Next.js stack reference); it provides most of the following out of the box via
config and plugins. FastAPI has no Python runtime for better-auth, so it uses
JWT (`PyJWT`) directly instead (see `fastapi-app/references/stack.md`). Prefer
better-auth's built-ins over hand-rolling wherever it's available. These are
the properties every app must end up with, whichever way auth is wired:

- **The backend is the security boundary, never the client.** A deployed API
  endpoint is reachable by anyone with `curl`, whether or not the web app or APK
  is public. Hiding the client (private release, obscure URL) is not a security
  control - it is obscurity. Gate access with real authentication, lockout, and
  (if the instance must stay private) a network gate such as Tailscale or
  Cloudflare Access. Never rely on "nobody knows the URL / has the app."
- **No open registration for single-owner / household apps.** The first user is
  created by a guarded setup flow (only when zero users exist) or a seed script -
  not a public signup route. Additional users are created only by an
  authenticated admin.
- **Never ship default or guessable credentials.** A seed script must not fall
  back to a hardcoded password (`changeme123`, `demo12345`, ...). If the password
  env var is unset, generate a strong random one and print it once; enforce a
  minimum length when provided. Public backend + known default password = instant
  takeover, and lockout never even triggers.
- **Brute-force lockout on login.** Count failed attempts and lock the account
  for a cooldown after a threshold (e.g. 5 attempts / 15 min). Store the counter
  in the database, not memory, so it survives stateless serverless invocations.
  A wrong 2FA code counts toward the same lockout.
- **TOTP 2FA is opt-in per user.** The secret is encrypted at rest, never stored
  plaintext. Backup codes are single-use and hashed (bcrypt). At login, a correct
  password with 2FA enabled but no code is *not* a failed attempt - it prompts for
  the code; a wrong code is a failed attempt.
- **Step-up (re-auth) for sensitive account changes.** Require the current
  password to BOTH enable and disable 2FA (asymmetry is a bug - a merely-open
  session must not be able to bind an attacker's authenticator or strip 2FA off),
  and for password change. An open session alone is not enough for these.
- **Encrypt recoverable secrets at rest** (TOTP seeds, BYOK provider API keys)
  with AES-256-GCM keyed from an env var (e.g. `TOTP_ENC_KEY`). One-way values
  (passwords) are hashed with bcrypt cost 12, never encrypted.
- **Privileged actions are gated server-side by role + session**, re-checked in
  the server action / route handler - never trusted from the client. Block
  self-service privilege escalation (a user promoting themselves to admin).
- **Generic auth errors.** "Invalid email or password" - never reveal whether the
  email exists. Do not leak lockout internals beyond "try again in N minutes."

## Flutter

- Release builds with obfuscation and split debug info:
  ```
  fvm flutter build appbundle --release \
    --obfuscate --split-debug-info=build/symbols
  ```
  Keep `build/symbols` out of git; archive it to symbolicate crashes.
- Android: keep R8 or ProGuard shrinking and obfuscation on for release. Do not
  disable minification.
- Never bundle API keys or secrets as assets or dart-defines that ship in the
  binary. BYOK keys stay in `flutter_secure_storage`; backend calls go through an
  authenticated server, not a key baked into the app.
- A `--dart-define`d backend URL (`API_BASE_URL` or similar) is a plain
  readable string in the compiled binary, not a secret exactly, but a real leak
  if the owner wants that backend's existence or address kept unlisted. If a
  release build is going to be publicly downloadable (a published GitHub
  Release, an app store listing), either make the server URL
  runtime-configurable (ask on first launch, store locally) instead of
  build-time, or keep the release as a **draft** (`draft: true` on
  `softprops/action-gh-release` or equivalent) so the artifact itself is never
  public - visible only to accounts with push access to the repo.
- Strip logging in release. Do not print tokens, payloads, or internal state.

## Next.js

- Production build only for deploys. Keep browser source maps off in production
  (`productionBrowserSourceMaps: false` unless you have a private symbolication
  need).
- Only expose env vars you intend to. Client code sees `NEXT_PUBLIC_` vars only;
  everything else is server-only. Never pass a server secret into a client
  component or a public env var.
- Keep data access and secrets in server components, server actions, and route
  handlers. The client bundle should carry no credentials and no privileged
  logic.
- Do not ship verbose error pages in production. Return generic errors; log
  detail server-side.

## FastAPI

- Disable or lock down the interactive docs and schema in production. Serve
  `/docs`, `/redoc`, and `/openapi.json` only in non-prod, or put them behind
  auth. Set `docs_url=None` and `openapi_url=None` when disabled.
- Return generic error bodies. Register exception handlers so no stack trace,
  SQL, or internal path reaches the client. Keep detail in structured logs.
- Turn debug off in production settings. Do not run with `--reload` or a debug
  server in prod.
- Lock CORS to known origins. Do not use a wildcard in production.
- Rate-limit auth and sensitive endpoints. Do not leak whether a user exists in
  login or reset responses.
