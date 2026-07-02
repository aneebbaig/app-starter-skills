# Security policy

## Scope

This repo ships instructions and small shell scripts, not a running service. The
scripts only make read-only HTTPS calls to public package registries (npm,
pub.dev, PyPI) to look up current versions. They install nothing and run no
untrusted code.

## Reporting

Found a problem (a script doing something unexpected, a supply-chain concern, or
guidance that would lead a project to leak secrets)? Open a private security
advisory on the repo, or email the maintainer. Do not open a public issue for a
sensitive report.

## Secrets

These skills never ask for or store secrets. The apps they scaffold are set up so
that secrets live in the platform secret store (GitHub Actions secrets, Vercel
env, platform keychain) and never in the repo. `.env*`, keystores, and
service-account files are gitignored from the first commit.
