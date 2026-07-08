# Intake: quick bootstrap, not an interrogation

New apps bootstrap FAST. Everything is a smart default (structure, packages,
auth=better-auth, hardening, latest versions via check-latest.sh). Ask only a
SHORT intake, 4 questions, each with a default pre-selected, then scaffold.

Ask these, in order, accepting defaults on Enter:

1. **App type** (default: internal-tool). Drives most other choices:
   - `internal-tool` / `admin-panel` → single owner or RBAC, private, no signup.
   - `saas` → multi-tenant, public signup, org/roles, billing-ready.
   - `marketing-site` / `portfolio` → mostly static + a small admin panel.
   - `mobile-backend` → API + better-auth bearer for a Flutter client.
2. **Open source or private?** (default: private), gates LICENSE/CONTRIBUTING/
   docs/CI per house-rules.md.
3. **Rough scale** (default: small, <1k users), only if `saas`; picks caching/
   connection-pooling/queue defaults. Skipped for other types.
4. **Deploy target** (default: Vercel + Neon), the standard; only ask if the
   type implies something else.

Do NOT ask about packages, structure, auth mechanism, lint, or versions; those
are fixed defaults from the standard. Only ask the 4 above; infer the rest from
**app type**. If the user gives the app type up front, ask nothing else unless a
choice is genuinely ambiguous.
