# Contributing to speed_ometer

Thanks for improving speed_ometer. Open an issue first for large changes so we can
agree on scope.

## Development setup

1. Fork and clone the repository.
2. Create a focused branch from the latest `main`.
3. Install the toolchain this repo already uses (Dart / Flutter (pub)) and any dependencies
   documented in the README.

## Making changes

- Keep the change set focused. Do not mix unrelated refactors with the fix.
- Add or update tests when the repo already has a test suite and the change
  alters behavior.
- Do not commit secrets, credentials, personal data, or generated build
  artifacts.
- Update the README when users need to know about the change.

Run the same checks the README documents before opening a pull request:

```sh
dart format --output=none --set-exit-if-changed .
dart analyze
```

## Pull requests

Explain why the change is needed, describe compatibility trade-offs, and list
the commands used to verify it. All required checks and review conversations
must be complete before merge.

Report security vulnerabilities privately according to
[`SECURITY.md`](SECURITY.md), not through a public issue.
