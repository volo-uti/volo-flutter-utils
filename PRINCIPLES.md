# Principles

Why this repository is built the way it is. Each principle says what we do, why, and which tool keeps us honest. Where no tool is named, the rule rests on review.

## Always the latest stable release

Tools and dependencies track the latest stable release; no beta or pre-release channels. Old versions pile up risk and make every later upgrade bigger. A dependency that has had no stable release for a year is a reason to reconsider the choice, not to pin it.

Enforced by: `make setup`, which installs the Flutter version from `.fvmrc`, and `dart pub outdated` during upgrades.

## Versions live in one place

A version number is written in a manifest (`.fvmrc`, `pubspec.yaml`) and nowhere else. Prose that repeats a version goes stale on the next upgrade, and a stale number is worse than none.

Enforced by: review. The workflows read `.fvmrc` instead of repeating the Flutter version.

## Rules are enforced by tools

A rule that only exists in a document gets forgotten. Naming and generated files are checked by scripts and lints. A rule that cannot be checked must say what breaks when it is ignored; if nothing breaks, it does not belong in a document.

Enforced by: `make check`, the analyzer in strict mode (`strict-casts`, `strict-inference`, `strict-raw-types`) and the lint set in `analysis_options.yaml`.

## One gate

Formatting, generated files, analysis and tests run behind a single command. People and coding agents run the same thing, and the `pre-push` hook runs it too, so "done" means one command passed, and its output is the evidence.

Enforced by: `make check`, run by the `pre-push` hook (`lefthook.yml`). Remote GitHub Actions do not run tests; they only publish.

## Whatever exists can be found

Every public declaration has a one-line summary taken from its doc comment, collected into a generated index in `AGENTS.md` and a doc file per source file. Writing a utility twice because nobody could find the first one is the failure this prevents. The API reference is generated from the doc comments instead of being rewritten by hand, so it cannot drift from the code.

Enforced by: `dart run tool/agent_index.dart --check` and `dart run tool/component_docs.dart --check`, both part of `make check`. They fail on a missing or over-long first sentence and on a stale index. Regenerate with `make index`.

## Agent-neutral guidance

The instructions for coding agents live in `AGENTS.md` and `.agents/skills/`, the files most agent tools already read. The only tool-specific files are a skills link for Claude and a one-line `CLAUDE.md` that imports `AGENTS.md`. Guidance is written once so it cannot diverge between tools.

Enforced by: review.

## Only the final state

Documents and code describe how things are now. They carry no "previously" sections and no migration notes; the history is in `git log`, and `CHANGELOG.md` and the release notes are built from its commit titles.

Enforced by: review.

## A version says what changed

A tag sits on its release commit (`chore(release): <version>`), the version is greater than the previous tag, and `CHANGELOG.md` has the version's entry. While the major version is 0 a release raises the patch, and a breaking change is listed under Breaking changes in the notes and the changelog. Apps take this library by tag, so a release that hides a breaking change breaks them without warning.

Enforced by: `make release-check`, which the release workflow runs again on the tag.

## Choices

The tools below were picked in this order: official or first-party, a stable release within the last six months, compatible with the current Flutter, then ecosystem adoption.

| Concern | Choice | Why |
|---|---|---|
| Flutter version | FVM, pinned in `.fvmrc` | Everyone, including the workflows, builds with the same SDK. |
| Repository layout | The repository root is the package | A git dependency takes the root as it is, so there is no second tool or nested folder to keep in step. |
| Language checks | Strict analyzer modes and `flutter_lints` | The first-party rule set, tightened where mistakes are likely. |
| Tests | `flutter_test` | First-party, with no code generation. |
| Generated docs | Own scripts in `tool/` reading `///` comments | The doc comment is the single source for index and docs. |
| Task runner | `make` | Present on every developer machine. |
