# Contributing

Thank you for your interest in contributing! This repository is the `volo_flutter_utils` package.

By taking part you agree to follow the [Code of Conduct](CODE_OF_CONDUCT.md). The reasons behind the design are in [PRINCIPLES.md](PRINCIPLES.md). [AGENTS.md](AGENTS.md) holds the full rules that humans and coding agents follow here.

## Development setup

Tool versions come from the manifests, not from this document: the Flutter version is in `.fvmrc` and the Dart SDK range is in each `pubspec.yaml`.

1. Install [FVM](https://fvm.app/) (`dart pub global activate fvm`).
2. Run `make setup`. It installs the Flutter version from `.fvmrc` and fetches dependencies.
3. Run `make check` to confirm that your setup works.

`make check` is the one gate. It checks formatting, the generated index and docs, static analysis and tests. There is no test CI: run it before you push. If [lefthook](https://lefthook.dev/) is installed, `make setup` installs a `pre-push` hook that runs it for you. On Windows, work inside WSL2.

Other commands:

```bash
make fmt      # format Dart files
make test     # run the tests of every package
make index    # rewrite the AGENTS.md index block and doc/
```

## Project structure

```
lib/              # Utilities (distributed through GitHub as volo_flutter_utils)
test/             # Tests
doc/              # Generated index and per-utility docs (shipped with the package)
bin/              # Command shipped to products
example/          # Minimal usage example
tool/             # Generators for the index and the per-declaration docs
```

## Coding conventions

The short version; see [AGENTS.md](AGENTS.md) for all of it.

- Public classes carry the `V` prefix (`VValidator`, `VDevice`). An extension on a core type is named `V<Type>Extension`.
- Every public declaration has a `///` doc comment. Its first sentence is at most 90 characters, because the generated index is built from it.
- Single quotes, trailing commas, type annotations on public APIs.
- Generated files (`doc/`) are never edited by hand. Rewrite them with `make index`.

## Adding a utility

1. Implement it in `lib/src/<section>/<file>.dart`, where the section is `extensions`, `helpers` or `validators`.
2. Add tests in `test/<section>/<file>_test.dart`.
3. Export it from the barrel `lib/volo_flutter_utils.dart`.
4. Run `make index`, then `make check`.

## Pull requests

1. Fork the repository and create a branch from the default branch.
2. Make your change, with tests.
3. Run `make index` if you changed a public API or its doc comment, then make sure `make check` passes.
4. Commit with [Conventional Commits](https://www.conventionalcommits.org/) in English: `<type>(<scope>): <subject>`.
5. Open a pull request and fill in the template. Write in English.

## Releasing

Maintainers release in this order.

1. Pick the version. It must be greater than the previous `v*` tag. While the major version is 0, every release raises the patch, a breaking change included (a commit title `type!:` or `type(scope)!:`, or a `BREAKING CHANGE:` line in the body); the Breaking changes section of the notes and the changelog announces it. From 1.0 on, a breaking change raises the major version.
2. Run `make changelog` to add the version's entry to `CHANGELOG.md`, then raise `version:` in `pubspec.yaml`, and commit both in a commit titled `chore(release): <version>`.
3. Run `make release-check` on that commit. It fails with one reason line when the title, the version, the version bump or the `CHANGELOG.md` entry is wrong. `make release-notes` previews the notes.
4. Put the tag on that release commit and push it. The release workflow runs the same check, then creates the GitHub release.

The release notes are built from the commit titles since the previous tag: Breaking changes, Features (`feat`) and Fixes (`fix`, `perf`). Other types are left out, so write each title for the people who read the notes. `CHANGELOG.md` collects the same lines per version, newest first; `make changelog` writes the entry, so do not edit it by hand.

## Reporting bugs and security problems

Open an [issue](https://github.com/volo-uti/volo-flutter-utils/issues/new/choose) for bugs and feature requests. Report security problems privately as described in [SECURITY.md](SECURITY.md); do not open a public issue for them.

## License

By contributing, you agree that your contributions are licensed under the [MIT License](LICENSE).
