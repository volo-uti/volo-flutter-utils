import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:volo_flutter_utils/volo_flutter_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('VPackage', () {
    tearDown(VPackage.clearCache);

    test('info maps the plugin values without a device', () async {
      PackageInfo.setMockInitialValues(
        appName: 'Demo',
        packageName: 'com.demo',
        version: '1.2.3',
        buildNumber: '45',
        buildSignature: 'sig',
        installerStore: 'store',
      );
      VPackage.clearCache();

      final info = await VPackage.info;
      expect(info.appName, 'Demo');
      expect(info.packageName, 'com.demo');
      expect(info.version, '1.2.3');
      expect(info.buildNumber, '45');
      expect(info.buildSignature, 'sig');
      expect(info.installerStore, 'store');
      expect(info.versionString, '1.2.3 (45)');
    });

    test('result is cached until clearCache', () async {
      PackageInfo.setMockInitialValues(
        appName: 'A',
        packageName: 'p',
        version: '1.0.0',
        buildNumber: '1',
        buildSignature: '',
      );
      VPackage.clearCache();
      final first = await VPackage.info;

      PackageInfo.setMockInitialValues(
        appName: 'B',
        packageName: 'p',
        version: '2.0.0',
        buildNumber: '2',
        buildSignature: '',
      );
      expect((await VPackage.info).version, '1.0.0');
      expect(await VPackage.info, same(first));

      VPackage.clearCache();
      expect((await VPackage.info).version, '2.0.0');
    });
  });

  group('VPackageInfo', () {
    test('constructor and properties', () {
      const info = VPackageInfo(
        appName: 'Test App',
        packageName: 'com.test.app',
        version: '1.0.0',
        buildNumber: '1',
        buildSignature: 'signature',
        installerStore: 'com.android.vending',
      );

      expect(info.appName, equals('Test App'));
      expect(info.packageName, equals('com.test.app'));
      expect(info.version, equals('1.0.0'));
      expect(info.buildNumber, equals('1'));
      expect(info.buildSignature, equals('signature'));
      expect(info.installerStore, equals('com.android.vending'));
    });

    test('versionString calculation', () {
      const info = VPackageInfo(
        appName: 'Test',
        packageName: 'com.test',
        version: '2.0.0',
        buildNumber: '42',
        buildSignature: '',
      );

      expect(info.versionString, equals('2.0.0 (42)'));
    });

    test('installerStore can be null', () {
      const info = VPackageInfo(
        appName: 'Test',
        packageName: 'com.test',
        version: '1.0.0',
        buildNumber: '1',
        buildSignature: '',
      );

      expect(info.installerStore, isNull);
    });

    test('toString output', () {
      const info = VPackageInfo(
        appName: 'Test',
        packageName: 'com.test',
        version: '1.0.0',
        buildNumber: '1',
        buildSignature: '',
      );

      expect(info.toString(), contains('VPackageInfo'));
      expect(info.toString(), contains('Test'));
      expect(info.toString(), contains('1.0.0'));
    });
  });
}
