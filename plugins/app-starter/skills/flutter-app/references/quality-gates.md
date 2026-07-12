# Flutter quality gates, CI, and release

## Local gates (run before every commit and in CI)

```
fvm flutter pub get
fvm dart run build_runner build --delete-conflicting-outputs   # if using codegen
fvm flutter analyze lib/     # must be zero issues
fvm flutter test
```

Zero analyzer issues is a hard gate. A lefthook or git pre-commit hook can run
analyze and test locally before a commit lands.

## CI workflow

`.github/workflows/ci.yml`, a job on PRs into `develop` and `main`:

```yaml
name: CI
on:
  pull_request:
    branches: [develop, main]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version-file: .fvmrc
          cache: true
      - run: flutter pub get
      - run: dart run build_runner build --delete-conflicting-outputs
      - run: flutter analyze
      - run: flutter test
```

`flutter-version-file: .fvmrc` reads the FVM-pinned version so CI matches
local dev exactly; do not use `channel: stable` here, it can drift to a
different Flutter version than what's pinned. Confirm the installed
flutter-action version actually supports reading `.fvmrc`; if not, pass the
pinned version explicitly via `flutter-version`. Pin action majors to current
when you write this. Skip the build_runner step when the project has no
codegen packages.

## Signing and secrets (Android)

- `android/key.properties` and `android/app/upload-keystore.jks`: gitignored.
  Store the keystore base64 and passwords as GitHub Actions secrets.
- `android/app/google-services.json`: gitignored, stored as a secret, written at
  build time.
- Back up the keystore. Losing it means you can never update the app.
- The Android application id is permanent after first Play Store publish. Choose
  `com.<owner>.<app>` deliberately.

## Release with release-please

- `release-please` opens a version + CHANGELOG PR from conventional commits on
  pushes to `main`. Merging it tags the release.
- A `release.yml` triggered on the `v*.*.*` tag builds a signed AAB and uploads
  it to the Play Store track. Never bump the pubspec version or tag by hand when
  release-please is in use.

## Verify before declaring done

`fvm flutter analyze lib/` clean, `fvm flutter test` green, and the app builds
and launches. Report real results, including analyzer output if not clean.
