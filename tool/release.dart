// Release rules and notes.
//
// `dart tool/release.dart check [--commit REV]` fails (exit 1, one reason line)
// when the commit REV (default HEAD) is not a valid release: its title must be
// `chore(release): <version>` for the version in pubspec.yaml, the version must
// be greater than the previous `v*` tag, and CHANGELOG.md at REV must have a
// `## <version>` entry. A breaking change may ship in a patch while the major
// version is 0; from 1.0 on it must raise the major version.
// `dart tool/release.dart notes [--commit REV]` prints the release notes built
// from the commit titles since the previous tag.
// `dart tool/release.dart changelog [--commit REV] [--version X.Y.Z]` adds the
// next version's entry, built the same way, to the top of CHANGELOG.md.
//
// Run it from inside the git repository; `make release-check`,
// `make release-notes` and `make changelog` do that.
import 'dart:io';

import 'src/release.dart';

void main(List<String> args) {
  exitCode = runRelease(args, out: stdout, err: stderr);
}
