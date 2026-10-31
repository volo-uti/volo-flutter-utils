import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/src/api.dart';

void main() {
  group('unexportedSources', () {
    late Directory root;
    const pkg = Pkg('demo_pkg', indexId: 'demo-pkg-index');

    void write(String path, [String text = '']) {
      File('${root.path}/$path')
        ..createSync(recursive: true)
        ..writeAsStringSync(text);
    }

    setUp(() => root = Directory.systemTemp.createTempSync('volo_api_test'));
    tearDown(() => root.deleteSync(recursive: true));

    test('is empty when every source file is exported', () {
      write('lib/demo_pkg.dart', '''
library;

export 'src/helpers/a.dart';
export 'package:demo_pkg/src/helpers/b.dart';
export "src/validators/c.dart" show C;
''');
      write('lib/src/helpers/a.dart');
      write('lib/src/helpers/b.dart');
      write('lib/src/validators/c.dart');

      expect(unexportedSources(pkg, root: root.path), isEmpty);
    });

    test('names a source file missing from the barrel', () {
      write('lib/demo_pkg.dart', "export 'src/helpers/a.dart';\n");
      write('lib/src/helpers/a.dart');
      write('lib/src/helpers/v_forgot.dart', 'class Forgot {}');

      expect(unexportedSources(pkg, root: root.path), [
        'lib/src/helpers/v_forgot.dart',
      ]);
    });

    test('a commented-out export does not count', () {
      write('lib/demo_pkg.dart', "// export 'src/helpers/a.dart';\n");
      write('lib/src/helpers/a.dart');

      expect(unexportedSources(pkg, root: root.path), [
        'lib/src/helpers/a.dart',
      ]);
    });

    test('this repository exports every source file', () {
      expect(
        unexportedSources(
          const Pkg('volo_flutter_utils', indexId: 'x'),
          root: Directory.current.path,
        ),
        isEmpty,
      );
    });
  });
}
