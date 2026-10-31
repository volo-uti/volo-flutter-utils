import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:volo_flutter_utils/volo_flutter_utils.dart';

const _channel = MethodChannel('dev.fluttercommunity.plus/device_info');

const _androidMap = <String, Object?>{
  'version': {
    'baseOS': '',
    'codename': 'REL',
    'incremental': '1',
    'release': '14',
    'previewSdkInt': 0,
    'sdkInt': 34,
    'securityPatch': '2024-01-01',
  },
  'board': 'b',
  'bootloader': 'bl',
  'brand': 'google',
  'device': 'd',
  'display': 'd',
  'fingerprint': 'f',
  'hardware': 'h',
  'host': 'h',
  'id': 'AP1A',
  'manufacturer': 'Google',
  'model': 'Pixel 8',
  'product': 'p',
  'tags': 't',
  'type': 'user',
  'isPhysicalDevice': true,
  'freeDiskSize': 1,
  'totalDiskSize': 2,
  'isLowRamDevice': false,
  'physicalRamSize': 1,
  'availableRamSize': 1,
};

void _mockDeviceInfo(Map<String, Object?> data) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_channel, (call) async => data);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null);
    VDevice.clearCache();
  });

  group('VDevice platform checks', () {
    test('each platform sets exactly one flag', () {
      final flags = <TargetPlatform, bool Function()>{
        TargetPlatform.android: () => VDevice.isAndroid,
        TargetPlatform.iOS: () => VDevice.isIOS,
        TargetPlatform.macOS: () => VDevice.isMacOS,
        TargetPlatform.windows: () => VDevice.isWindows,
        TargetPlatform.linux: () => VDevice.isLinux,
      };
      for (final target in flags.keys) {
        debugDefaultTargetPlatformOverride = target;
        for (final entry in flags.entries) {
          expect(entry.value(), entry.key == target, reason: '$target');
        }
      }
    });

    test('mobile and desktop groupings', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      expect([VDevice.isMobile, VDevice.isDesktop], [true, false]);
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      expect([VDevice.isMobile, VDevice.isDesktop], [true, false]);
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      expect([VDevice.isMobile, VDevice.isDesktop], [false, true]);
      debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
      expect([VDevice.isMobile, VDevice.isDesktop], [false, false]);
    });

    test('isWeb is false in the VM test environment', () {
      expect(VDevice.isWeb, isFalse);
    });
  });

  group('VDevice.info', () {
    test('Android maps the plugin fields', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      _mockDeviceInfo(_androidMap);
      VDevice.plugin = DeviceInfoPlugin();

      final info = await VDevice.info;
      expect(info.platform, 'Android');
      expect(info.model, 'Pixel 8');
      expect(info.osVersion, 'Android 14');
      expect(info.manufacturer, 'Google');
      expect(info.isPhysicalDevice, isTrue);
      expect(info.deviceId, 'AP1A');
    });

    test('iOS maps the plugin fields', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      _mockDeviceInfo({
        'name': 'n',
        'systemName': 'iOS',
        'systemVersion': '17.4',
        'model': 'iPhone',
        'modelName': 'iPhone 15',
        'localizedModel': 'iPhone',
        'identifierForVendor': 'vendor-1',
        'freeDiskSize': 1,
        'totalDiskSize': 2,
        'isPhysicalDevice': false,
        'physicalRamSize': 1,
        'availableRamSize': 1,
        'isiOSAppOnMac': false,
        'isiOSAppOnVision': false,
        'utsname': {
          'sysname': 's',
          'nodename': 'n',
          'release': 'r',
          'version': 'v',
          'machine': 'm',
        },
      });
      VDevice.plugin = DeviceInfoPlugin();

      final info = await VDevice.info;
      expect(info.platform, 'iOS');
      expect(info.osVersion, 'iOS 17.4');
      expect(info.manufacturer, 'Apple');
      expect(info.isPhysicalDevice, isFalse);
      expect(info.deviceId, 'vendor-1');
    });

    test('unsupported platform gives Unknown fields', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
      VDevice.plugin = DeviceInfoPlugin();

      final info = await VDevice.info;
      expect(info.platform, 'Unknown');
      expect(info.model, 'Unknown');
      expect(info.osVersion, 'Unknown');
      expect(info.manufacturer, 'Unknown');
      expect(info.isPhysicalDevice, isFalse);
      expect(info.deviceId, isNull);
    });

    test('result is cached until clearCache', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
      VDevice.plugin = DeviceInfoPlugin();
      expect((await VDevice.info).platform, 'Unknown');

      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      _mockDeviceInfo(_androidMap);
      expect((await VDevice.info).platform, 'Unknown');

      VDevice.clearCache();
      expect((await VDevice.info).platform, 'Android');
    });
  });

  group('VDeviceInfo', () {
    test('constructor and toString', () {
      const info = VDeviceInfo(
        platform: 'Test',
        model: 'TestModel',
        osVersion: 'TestOS 1.0',
        manufacturer: 'TestManufacturer',
        isPhysicalDevice: true,
        deviceId: 'test-id',
      );

      expect(info.platform, equals('Test'));
      expect(info.model, equals('TestModel'));
      expect(info.osVersion, equals('TestOS 1.0'));
      expect(info.manufacturer, equals('TestManufacturer'));
      expect(info.isPhysicalDevice, isTrue);
      expect(info.deviceId, equals('test-id'));
      expect(info.toString(), contains('VDeviceInfo'));
      expect(info.toString(), contains('test-id'));
    });

    test('deviceId can be null', () {
      const info = VDeviceInfo(
        platform: 'Test',
        model: 'TestModel',
        osVersion: 'TestOS 1.0',
        manufacturer: 'TestManufacturer',
        isPhysicalDevice: false,
      );

      expect(info.deviceId, isNull);
    });
  });
}
