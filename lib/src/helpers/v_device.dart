import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

/// Platform checks and a cached summary of the current device.
///
/// The `is…` getters follow `defaultTargetPlatform`, so they are false on the
/// web (except [isWeb]) and tests can switch them with
/// `debugDefaultTargetPlatformOverride`. [info] wraps `device_info_plus` and
/// supports Android, iOS, macOS, Windows, Linux and the web; any other
/// platform gets a `VDeviceInfo` whose fields are all `'Unknown'`. In tests,
/// mock the plugin's method channel and call [clearCache].
///
/// ```dart
/// if (VDevice.isMobile) {
///   final info = await VDevice.info;
///   info.model;     // 'Pixel 8'
///   info.osVersion; // 'Android 14'
/// }
/// ```
class VDevice {
  VDevice._();

  static VDeviceInfo? _cachedInfo;

  /// The plugin [info] reads from; replace it in tests, then [clearCache].
  @visibleForTesting
  static DeviceInfoPlugin plugin = DeviceInfoPlugin();

  /// Device summary, read once from the platform and then cached.
  static Future<VDeviceInfo> get info async {
    if (_cachedInfo != null) return _cachedInfo!;
    _cachedInfo = await _getDeviceInfo();
    return _cachedInfo!;
  }

  /// Drops the cached [info] so the next read asks the platform again.
  static void clearCache() {
    _cachedInfo = null;
  }

  /// Whether the app runs in a browser.
  static bool get isWeb => kIsWeb;

  /// Whether the app runs on Android (never true on the web).
  static bool get isAndroid => _is(TargetPlatform.android);

  /// Whether the app runs on iOS (never true on the web).
  static bool get isIOS => _is(TargetPlatform.iOS);

  /// Whether the app runs on macOS (never true on the web).
  static bool get isMacOS => _is(TargetPlatform.macOS);

  /// Whether the app runs on Windows (never true on the web).
  static bool get isWindows => _is(TargetPlatform.windows);

  /// Whether the app runs on Linux (never true on the web).
  static bool get isLinux => _is(TargetPlatform.linux);

  /// Whether the app runs on Android or iOS.
  static bool get isMobile => isAndroid || isIOS;

  /// Whether the app runs on macOS, Windows or Linux.
  static bool get isDesktop => isMacOS || isWindows || isLinux;

  static bool _is(TargetPlatform platform) =>
      !kIsWeb && defaultTargetPlatform == platform;

  static Future<VDeviceInfo> _getDeviceInfo() async {
    if (kIsWeb) {
      final webInfo = await plugin.webBrowserInfo;
      return VDeviceInfo(
        platform: 'Web',
        model: webInfo.browserName.name,
        osVersion: webInfo.platform ?? 'Unknown',
        manufacturer: webInfo.vendor ?? 'Unknown',
        isPhysicalDevice: false,
      );
    }

    if (isAndroid) {
      final androidInfo = await plugin.androidInfo;
      return VDeviceInfo(
        platform: 'Android',
        model: androidInfo.model,
        osVersion: 'Android ${androidInfo.version.release}',
        manufacturer: androidInfo.manufacturer,
        isPhysicalDevice: androidInfo.isPhysicalDevice,
        deviceId: androidInfo.id,
      );
    }

    if (isIOS) {
      final iosInfo = await plugin.iosInfo;
      return VDeviceInfo(
        platform: 'iOS',
        model: iosInfo.model,
        osVersion: '${iosInfo.systemName} ${iosInfo.systemVersion}',
        manufacturer: 'Apple',
        isPhysicalDevice: iosInfo.isPhysicalDevice,
        deviceId: iosInfo.identifierForVendor,
      );
    }

    if (isMacOS) {
      final macInfo = await plugin.macOsInfo;
      return VDeviceInfo(
        platform: 'macOS',
        model: macInfo.model,
        osVersion: 'macOS ${macInfo.osRelease}',
        manufacturer: 'Apple',
        isPhysicalDevice: true,
        deviceId: macInfo.systemGUID,
      );
    }

    if (isWindows) {
      final windowsInfo = await plugin.windowsInfo;
      return VDeviceInfo(
        platform: 'Windows',
        model: windowsInfo.productName,
        osVersion: 'Windows ${windowsInfo.displayVersion}',
        manufacturer: 'Microsoft',
        isPhysicalDevice: true,
        deviceId: windowsInfo.deviceId,
      );
    }

    if (isLinux) {
      final linuxInfo = await plugin.linuxInfo;
      return VDeviceInfo(
        platform: 'Linux',
        model: linuxInfo.prettyName,
        osVersion: linuxInfo.versionId ?? 'Unknown',
        manufacturer: 'Unknown',
        isPhysicalDevice: true,
        deviceId: linuxInfo.machineId,
      );
    }

    return const VDeviceInfo(
      platform: 'Unknown',
      model: 'Unknown',
      osVersion: 'Unknown',
      manufacturer: 'Unknown',
      isPhysicalDevice: false,
    );
  }
}

/// Snapshot of the current device, as read by [VDevice.info].
class VDeviceInfo {
  /// Creates a snapshot from the given values.
  const VDeviceInfo({
    required this.platform,
    required this.model,
    required this.osVersion,
    required this.manufacturer,
    required this.isPhysicalDevice,
    this.deviceId,
  });

  /// Platform name: Android, iOS, Web, macOS, Windows, Linux or Unknown.
  final String platform;

  /// Device model name.
  final String model;

  /// OS name and version such as `Android 14`; `Unknown` if the platform has none.
  final String osVersion;

  /// Maker such as `Apple`; `Unknown` when the platform does not report it.
  final String manufacturer;

  /// Whether this is real hardware; always true on desktop, false on the web.
  final bool isPhysicalDevice;

  /// Identifier the platform exposes, or null when it has none.
  ///
  /// Its meaning differs per platform (Android build id, iOS vendor id, macOS
  /// hardware UUID, Windows device id, Linux machine id) and some change on
  /// reinstall, so treat it as personal data and do not rely on it for identity.
  final String? deviceId;

  @override
  String toString() =>
      '''
VDeviceInfo(
  platform: $platform,
  model: $model,
  osVersion: $osVersion,
  manufacturer: $manufacturer,
  isPhysicalDevice: $isPhysicalDevice,
  deviceId: $deviceId,
)''';
}
