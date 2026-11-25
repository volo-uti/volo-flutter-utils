// Core of the release rules and the release notes. It reads only the local git
// repository (no network, no remote) and imports only `dart:*`, so
// `dart tool/release.dart` runs without `pub get`.
//
// A release is a commit titled `chore(release): <version>` that raises the
// `version:` of pubspec.yaml and has a `## <version>` entry in CHANGELOG.md.
// The version must be greater than the one of the previous `v*` tag; a
// breaking change may ship in a patch while the major version is 0 and is
// announced in the Breaking changes section. From 1.0 on, a breaking change
// must raise the major version.
import 'dart:io';

/// A release rule that does not hold, or a git repository that cannot be read.
class ReleaseException implements Exception {
  /// Creates an exception with a one-line [message].
  ReleaseException(this.message, {this.usage = false});

  /// One-line reason.
  final String message;

  /// True when the input was unusable (exit 2) rather than a rule broken
  /// (exit 1).
  final bool usage;

  @override
  String toString() => message;
}

/// A `major.minor.patch` version.
class ReleaseVersion implements Comparable<ReleaseVersion> {
  /// Creates a version from its three numbers.
  const ReleaseVersion(this.major, this.minor, this.patch);

  /// Parses `1.2.3`, `v1.2.3` or `1.2.3+4` / `1.2.3-pre`; null when it does not
  /// start with three numbers.
  static ReleaseVersion? tryParse(String text) {
    final m = RegExp(r'^v?(\d+)\.(\d+)\.(\d+)').firstMatch(text.trim());
    if (m == null) return null;
    return ReleaseVersion(
      int.parse(m.group(1)!),
      int.parse(m.group(2)!),
      int.parse(m.group(3)!),
    );
  }

  /// Major number.
  final int major;

  /// Minor number.
  final int minor;

  /// Patch number.
  final int patch;

  @override
  int compareTo(ReleaseVersion other) {
    if (major != other.major) return major.compareTo(other.major);
    if (minor != other.minor) return minor.compareTo(other.minor);
    return patch.compareTo(other.patch);
  }

  @override
  String toString() => '$major.$minor.$patch';
}

/// One commit read from `git log`.
class ReleaseCommit {
  /// Creates a commit from its parts.
  const ReleaseCommit({
    required this.hash,
    required this.subject,
    required this.body,
  });

  /// Full hash.
  final String hash;

  /// First line of the message.
  final String subject;

  /// Message after the first line.
  final String body;

  static final _subject = RegExp(r'^(\w+)(?:\(([^)]*)\))?(!)?:\s*(.+)$');

  /// Conventional Commits type, or null when the subject has none.
  String? get type => _subject.firstMatch(subject)?.group(1);

  /// Scope in parentheses, or null.
  String? get scope => _subject.firstMatch(subject)?.group(2);

  /// Subject without the `type(scope)!: ` prefix.
  String get description => _subject.firstMatch(subject)?.group(4) ?? subject;

  /// True for `type!:`, `type(scope)!:` or a `BREAKING CHANGE:` body line.
  bool get isBreaking {
    if (_subject.firstMatch(subject)?.group(3) != null) return true;
    return body
        .split('\n')
        .any((l) => RegExp('^BREAKING[ -]CHANGE:').hasMatch(l));
  }
}

String _git(List<String> args, String dir) {
  final ProcessResult r;
  try {
    r = Process.runSync('git', args, workingDirectory: dir);
  } on ProcessException catch (e) {
    throw ReleaseException('cannot run git: ${e.message}', usage: true);
  }
  if (r.exitCode != 0) {
    throw ReleaseException(
      'git ${args.join(' ')} failed: ${(r.stderr as String).trim()}',
      usage: true,
    );
  }
  return r.stdout as String;
}

/// The nearest `v*` tag behind [rev], or null when there is none.
///
/// The search starts at the parent of [rev], so a tag on [rev] itself (the
/// release workflow runs on the tagged commit) is skipped.
String? previousTag(String rev, {String dir = '.'}) {
  final r = Process.runSync('git', [
    'describe',
    '--tags',
    '--abbrev=0',
    '--match',
    'v*',
    '$rev^',
  ], workingDirectory: dir);
  if (r.exitCode != 0) return null;
  final tag = (r.stdout as String).trim();
  return tag.isEmpty ? null : tag;
}

/// The commits in `tag..rev`, newest first; the whole history without a tag.
List<ReleaseCommit> commitsSince(String? tag, String rev, {String dir = '.'}) {
  final out = _git([
    'log',
    '--format=%H%x1f%s%x1f%b%x1e',
    if (tag == null) rev else '$tag..$rev',
  ], dir);
  final commits = <ReleaseCommit>[];
  for (final record in out.split('\x1e')) {
    final text = record.trim();
    if (text.isEmpty) continue;
    final parts = text.split('\x1f');
    commits.add(
      ReleaseCommit(
        hash: parts[0],
        subject: parts.length > 1 ? parts[1] : '',
        body: parts.length > 2 ? parts[2] : '',
      ),
    );
  }
  return commits;
}

/// The `version:` of pubspec.yaml at [rev], as written and parsed.
(String, ReleaseVersion) _pubspecVersion(String rev, String dir) {
  final pubspec = _git(['show', '$rev:pubspec.yaml'], dir);
  final text = RegExp(
    r'^version:\s*(\S+)',
    multiLine: true,
  ).firstMatch(pubspec)?.group(1);
  final version = text == null ? null : ReleaseVersion.tryParse(text);
  if (text == null || version == null) {
    throw ReleaseException('pubspec.yaml has no usable version: line');
  }
  return (text, version);
}

/// True when [changelog] has a `## <version>` heading.
bool _hasEntry(String changelog, ReleaseVersion version) =>
    changelog.split('\n').any((l) => l.trimRight() == '## $version');

/// Checks the release rules for the commit [rev] and returns a one-line
/// summary; throws [ReleaseException] with the reason when a rule fails.
String checkRelease(String rev, {String dir = '.'}) {
  final subject = _git(['log', '-1', '--format=%s', rev], dir).trim();
  final (versionText, version) = _pubspecVersion(rev, dir);
  if (subject != 'chore(release): $versionText') {
    throw ReleaseException(
      'the commit title must be "chore(release): $versionText", '
      'it is "$subject"',
    );
  }
  final changelog = Process.runSync('git', [
    'show',
    '$rev:CHANGELOG.md',
  ], workingDirectory: dir);
  if (changelog.exitCode != 0 ||
      !_hasEntry(changelog.stdout as String, version)) {
    throw ReleaseException(
      'CHANGELOG.md at $rev has no "## $version" entry; '
      'run `make changelog` and commit it',
    );
  }
  final tag = previousTag(rev, dir: dir);
  final previous = tag == null ? null : ReleaseVersion.tryParse(tag);
  if (tag == null || previous == null) {
    return 'release $version, no previous tag, breaking changes 0';
  }
  if (version.compareTo(previous) <= 0) {
    throw ReleaseException(
      'version $version is not greater than the previous tag $tag',
    );
  }
  final breaking = commitsSince(
    tag,
    rev,
    dir: dir,
  ).where((c) => c.isBreaking).length;
  if (breaking > 0 && previous.major > 0 && version.major <= previous.major) {
    throw ReleaseException(
      '$breaking breaking change(s) since $tag, so the major version must '
      'go up ($tag -> $version)',
    );
  }
  return 'release $version, previous tag $tag, breaking changes $breaking';
}

/// Markdown release notes for `previousTag..rev`: breaking changes, features
/// and fixes. Empty sections are left out.
String releaseNotes(String rev, {String dir = '.'}) => _sections(
  commitsSince(previousTag(rev, dir: dir), rev, dir: dir),
  heading: '##',
);

/// The notes sections for [commits] under [heading] titles; empty when no
/// commit is a breaking change, a feature or a fix.
String _sections(List<ReleaseCommit> commits, {required String heading}) {
  final breaking = <String>[];
  final features = <String>[];
  final fixes = <String>[];
  for (final c in commits) {
    final scope = c.scope;
    final line =
        '- ${scope == null || scope.isEmpty ? '' : '**$scope:** '}'
        '${c.description} (${c.hash.substring(0, 7)})';
    if (c.isBreaking) {
      breaking.add(line);
    } else if (c.type == 'feat') {
      features.add(line);
    } else if (c.type == 'fix' || c.type == 'perf') {
      fixes.add(line);
    }
  }
  final out = StringBuffer();
  void section(String title, List<String> lines) {
    if (lines.isEmpty) return;
    if (out.isNotEmpty) out.writeln();
    out
      ..writeln('$heading $title')
      ..writeln()
      ..writeln(lines.join('\n'));
  }

  section('Breaking changes', breaking);
  section('Features', features);
  section('Fixes', fixes);
  return out.toString();
}

/// Adds the entry of the next version to the top of CHANGELOG.md at the root
/// of the git repository that holds [dir], and returns a one-line summary.
///
/// The entry lists the commits since the nearest `v*` tag reachable from
/// [rev] (a tag on [rev] counts, the tag of the version being written does
/// not), in the sections of the release notes. The version is [version], else
/// the pubspec version at [rev] when it is greater than that tag, else the
/// tag's patch plus one. Throws [ReleaseException] and leaves the file alone
/// when the entry is already there. It never commits.
String writeChangelog(String rev, {String? version, String dir = '.'}) {
  final root = _git(['rev-parse', '--show-toplevel'], dir).trim();
  final explicit = version == null ? null : ReleaseVersion.tryParse(version);
  if (version != null && explicit == null) {
    throw ReleaseException('not a version: $version', usage: true);
  }
  String? tagBehind({String? exclude}) {
    final r = Process.runSync('git', [
      'describe',
      '--tags',
      '--abbrev=0',
      '--match',
      'v*',
      if (exclude != null) ...['--exclude', exclude],
      rev,
    ], workingDirectory: root);
    final tag = (r.stdout as String).trim();
    return r.exitCode != 0 || tag.isEmpty ? null : tag;
  }

  ReleaseVersion next;
  if (explicit != null) {
    next = explicit;
  } else {
    final tag = tagBehind();
    final previous = tag == null ? null : ReleaseVersion.tryParse(tag);
    final (_, current) = _pubspecVersion(rev, root);
    next = previous == null || current.compareTo(previous) > 0
        ? current
        : ReleaseVersion(previous.major, previous.minor, previous.patch + 1);
  }
  final tag = tagBehind(exclude: 'v$next');
  final file = File('$root/CHANGELOG.md');
  final old = file.existsSync() ? file.readAsStringSync() : '';
  if (_hasEntry(old, next)) {
    throw ReleaseException('CHANGELOG.md already has a "## $next" entry');
  }
  final sections = _sections(commitsSince(tag, rev, dir: root), heading: '###');
  final entry =
      '## $next\n\n${sections.isEmpty ? 'No notable changes.\n' : sections}';
  final lines = old.split('\n');
  final title = lines.indexWhere((l) => l.trimRight() == '# Changelog');
  final String text;
  if (title < 0) {
    text =
        '# Changelog\n\n$entry${old.trim().isEmpty ? '' : '\n${old.trimLeft()}'}';
  } else {
    final before = lines.sublist(0, title + 1).join('\n');
    final after = lines.sublist(title + 1).join('\n').trimLeft();
    text = '$before\n\n$entry${after.isEmpty ? '' : '\n$after'}';
  }
  file.writeAsStringSync(text);
  return 'CHANGELOG.md: added $next (since ${tag ?? 'the first commit'})';
}

/// Runs the command line: `check`, `notes` or `changelog`, with `--commit REV`
/// (default `HEAD`) and, for `changelog`, `--version X.Y.Z`. Returns the exit
/// code: 0 ok, 1 a rule fails, 2 unusable input.
int runRelease(
  List<String> args, {
  required StringSink out,
  required StringSink err,
  String dir = '.',
}) {
  final command = args.isEmpty ? null : args.first;
  var rev = 'HEAD';
  String? version;
  final rest = args.skip(1).toList();
  for (var i = 0; i < rest.length; i++) {
    if (rest[i] == '--commit' && i + 1 < rest.length) {
      rev = rest[++i];
    } else if (command == 'changelog' &&
        rest[i] == '--version' &&
        i + 1 < rest.length) {
      version = rest[++i];
    } else {
      err.writeln('unknown argument: ${rest[i]}');
      return 2;
    }
  }
  try {
    switch (command) {
      case 'check':
        out.writeln(checkRelease(rev, dir: dir));
        return 0;
      case 'notes':
        out.write(releaseNotes(rev, dir: dir));
        return 0;
      case 'changelog':
        out.writeln(writeChangelog(rev, version: version, dir: dir));
        return 0;
      default:
        err.writeln(
          'usage: dart tool/release.dart check|notes|changelog '
          '[--commit REV] [--version X.Y.Z]',
        );
        return 2;
    }
  } on ReleaseException catch (e) {
    err.writeln(e.message);
    return e.usage ? 2 : 1;
  }
}
