import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/src/release.dart';

/// A throw-away git repository with a `pubspec.yaml`.
class _Repo {
  _Repo() : dir = Directory.systemTemp.createTempSync('release_test_') {
    _git(['init', '-q', '-b', 'main']);
    _git(['config', 'user.name', 'Test']);
    _git(['config', 'user.email', 'test@example.com']);
    _git(['config', 'commit.gpgsign', 'false']);
    _git(['config', 'tag.gpgsign', 'false']);
  }

  final Directory dir;

  void _git(List<String> args) {
    final r = Process.runSync('git', args, workingDirectory: dir.path);
    if (r.exitCode != 0) fail('git ${args.join(' ')}: ${r.stderr}');
  }

  void commit(String message, {String? version}) {
    File('${dir.path}/pubspec.yaml')
        .writeAsStringSync('name: sample\nversion: ${version ?? _version}\n');
    if (version != null) _version = version;
    File('${dir.path}/n.txt').writeAsStringSync('$message ${_n++}');
    File('${dir.path}/CHANGELOG.md')
        .writeAsStringSync('# Changelog\n\n## ${version ?? _version}\n');
    _git(['add', '-A']);
    _git(['commit', '-q', '-m', message]);
  }

  void tag(String name) => _git(['tag', name]);

  String _version = '0.1.3';
  int _n = 0;

  String check() => checkRelease('HEAD', dir: dir.path);

  void dispose() => dir.deleteSync(recursive: true);
}

void main() {
  late _Repo repo;

  setUp(() {
    repo = _Repo()
      ..commit('feat: first')
      ..tag('v0.1.3');
  });
  tearDown(() => repo.dispose());

  group('checkRelease', () {
    test('accepts a patch bump when there is no breaking change', () {
      repo
        ..commit('fix(a): a fix')
        ..commit('chore(release): 0.1.4', version: '0.1.4');
      expect(repo.check(), contains('0.1.4'));
    });

    test('rejects a commit that is not a release commit', () {
      repo.commit('fix: a fix', version: '0.1.4');
      expect(repo.check, throwsA(isA<ReleaseException>()));
    });

    test('rejects a version that is not greater than the previous tag', () {
      repo.commit('chore(release): 0.1.3');
      expect(repo.check, throwsA(isA<ReleaseException>()));
    });

    test('accepts a patch bump after a breaking subject', () {
      repo
        ..commit('fix(tabs)!: announce tabs')
        ..commit('chore(release): 0.1.4', version: '0.1.4');
      expect(repo.check(), contains('breaking changes 1'));
    });

    test('accepts a minor bump after a breaking subject', () {
      repo
        ..commit('feat!: drop it')
        ..commit('chore(release): 0.2.0', version: '0.2.0');
      expect(repo.check(), contains('0.2.0'));
    });

    test('counts a BREAKING CHANGE body line', () {
      repo
        ..commit('feat: x\n\nBREAKING CHANGE: y is gone')
        ..commit('chore(release): 0.1.4', version: '0.1.4');
      expect(repo.check(), contains('breaking changes 1'));
    });

    test('skips a tag on the release commit itself', () {
      repo
        ..commit('fix: a fix')
        ..commit('chore(release): 0.1.4', version: '0.1.4')
        ..tag('v0.1.4');
      expect(repo.check(), contains('v0.1.3'));
    });

    test('rejects a release without its CHANGELOG entry', () {
      repo.commit('chore(release): 0.1.4', version: '0.1.4');
      File('${repo.dir.path}/CHANGELOG.md').writeAsStringSync('# Changelog\n');
      repo._git(['commit', '-q', '-a', '--amend', '--no-edit']);
      expect(repo.check, throwsA(isA<ReleaseException>()));
    });

    test('after 1.0 a breaking change must raise the major', () {
      repo
        ..commit('chore(release): 1.0.0', version: '1.0.0')
        ..tag('v1.0.0')
        ..commit('fix!: gone')
        ..commit('chore(release): 1.1.0', version: '1.1.0');
      expect(repo.check, throwsA(isA<ReleaseException>()));
    });
  });

  group('releaseNotes', () {
    test('groups breaking changes, features and fixes', () {
      repo
        ..commit('feat(x): new thing')
        ..commit('fix: a bug')
        ..commit('perf: faster')
        ..commit('fix(tabs)!: announce tabs')
        ..commit('docs: words')
        ..commit('chore: tidy')
        ..commit('refactor: shuffle');
      final notes = releaseNotes('HEAD', dir: repo.dir.path);
      expect(notes, contains('## Breaking changes'));
      expect(notes, contains('## Features'));
      expect(notes, contains('## Fixes'));
      expect(notes, contains('**x:** new thing'));
      expect(notes, contains('a bug'));
      expect(notes, contains('faster'));
      expect(notes, contains('announce tabs'));
      expect('announce tabs'.allMatches(notes), hasLength(1));
      expect(notes, isNot(contains('words')));
      expect(notes, isNot(contains('tidy')));
      expect(notes, isNot(contains('shuffle')));
    });

    test('leaves out an empty section', () {
      repo.commit('fix: only a fix');
      final notes = releaseNotes('HEAD', dir: repo.dir.path);
      expect(notes, contains('## Fixes'));
      expect(notes, isNot(contains('## Breaking changes')));
      expect(notes, isNot(contains('## Features')));
    });
  });

  group('writeChangelog', () {
    test('adds the next entry on top with the notes lines', () {
      repo
        ..commit('feat(x): new thing')
        ..commit('fix: a bug')
        ..commit('docs: words');
      File('${repo.dir.path}/CHANGELOG.md')
          .writeAsStringSync('# Changelog\n\n## 0.1.3\n\n- old\n');
      expect(writeChangelog('HEAD', dir: repo.dir.path), contains('0.1.4'));
      final log = File('${repo.dir.path}/CHANGELOG.md').readAsStringSync();
      expect(log, startsWith('# Changelog\n\n## 0.1.4\n\n### Features\n'));
      expect(log, contains('**x:** new thing'));
      expect(log, contains('### Fixes'));
      expect(log, isNot(contains('words')));
      expect(log.indexOf('## 0.1.4'), lessThan(log.indexOf('## 0.1.3')));
      expect(log, contains('- old'));
    });

    test('refuses an entry that is already there', () {
      repo.commit('fix: a bug');
      writeChangelog('HEAD', dir: repo.dir.path);
      final once = File('${repo.dir.path}/CHANGELOG.md').readAsStringSync();
      expect(
        () => writeChangelog('HEAD', dir: repo.dir.path),
        throwsA(isA<ReleaseException>()),
      );
      expect(File('${repo.dir.path}/CHANGELOG.md').readAsStringSync(), once);
    });

    test('takes an explicit version for a past tag', () {
      repo
        ..commit('feat: later')
        ..tag('v0.1.4');
      writeChangelog('v0.1.4', version: '0.1.4', dir: repo.dir.path);
      final log = File('${repo.dir.path}/CHANGELOG.md').readAsStringSync();
      expect(log, contains('## 0.1.4'));
      expect(log, contains('later'));
      expect(log, isNot(contains('first')));
    });
  });

  group('runRelease', () {
    test('exits 1 with a reason when a rule fails', () {
      repo.commit('fix: not a release');
      final out = StringBuffer();
      final err = StringBuffer();
      final code = runRelease(
        ['check'],
        out: out,
        err: err,
        dir: repo.dir.path,
      );
      expect(code, 1);
      expect(err.toString().trim(), isNotEmpty);
    });

    test('exits 2 on a bad command', () {
      final code = runRelease(
        ['nope'],
        out: StringBuffer(),
        err: StringBuffer(),
        dir: repo.dir.path,
      );
      expect(code, 2);
    });
  });
}
