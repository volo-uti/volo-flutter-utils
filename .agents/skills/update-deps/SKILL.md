---
name: update-deps
description: Use for the regular check that upgrades the Flutter SDK and dependencies. Follow it for the monthly check or any request to bump versions.
---

# Upgrade dependencies

1. Compare the Flutter version in `.fvmrc` with the latest stable release. If you raise it, edit `.fvmrc` and run `fvm install`.
2. From the repository root, run `fvm flutter pub outdated` to see outdated direct dependencies.
3. From the repository root, run `fvm flutter pub upgrade --major-versions`.
4. Do not raise the range that products receive (the upper end under `environment` in `pubspec.yaml`) ahead of products. If it went up, revert it.
5. Run `make setup check`. Fix what the upgrade broke; if it cannot be fixed quickly, revert only that package and record it as blocked.
6. Report what was upgraded (old -> new version) and what is blocked, with the reason.
