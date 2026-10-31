import 'package:package_info_plus/package_info_plus.dart';

/// Reads the running app's name, version and build number once and caches it.
///
/// Wraps `package_info_plus`, which asks the native side on Android, iOS,
/// macOS, Windows and Linux; fields a platform lacks come back empty
/// ([VPackageInfo.buildSignature] is filled on Android only). In tests, call
/// `PackageInfo.setMockInitialValues` and [clearCache] first.
///
/// ```dart
/// final info = await VPackage.info;
/// info.version;       // '1.0.0'
/// info.versionString; // '1.0.0 (1)'
/// ```
class VPackage {
  VPackage._();

  static VPackageInfo? _cachedInfo;

  /// The app's package information, read once and then cached.
  static Future<VPackageInfo> get info async {
    if (_cachedInfo != null) return _cachedInfo!;
    _cachedInfo = await _getPackageInfo();
    return _cachedInfo!;
  }

  /// Drops the cached [info] so the next read asks the platform again.
  static void clearCache() {
    _cachedInfo = null;
  }

  static Future<VPackageInfo> _getPackageInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return VPackageInfo(
      appName: packageInfo.appName,
      packageName: packageInfo.packageName,
      version: packageInfo.version,
      buildNumber: packageInfo.buildNumber,
      buildSignature: packageInfo.buildSignature,
      installerStore: packageInfo.installerStore,
    );
  }
}

/// Snapshot of the app's package metadata, as read by [VPackage.info].
class VPackageInfo {
  /// Creates a snapshot from the given values.
  const VPackageInfo({
    required this.appName,
    required this.packageName,
    required this.version,
    required this.buildNumber,
    required this.buildSignature,
    this.installerStore,
  });

  /// App display name.
  final String appName;

  /// Package name (bundle identifier).
  final String packageName;

  /// Version (e.g., '1.0.0').
  final String version;

  /// Build number.
  final String buildNumber;

  /// Signing certificate hash; filled on Android only, empty elsewhere.
  final String buildSignature;

  /// Store that installed the app (e.g. `com.android.vending`), if known.
  final String? installerStore;

  /// The version and build number as `1.0.0 (1)`.
  String get versionString => '$version ($buildNumber)';

  @override
  String toString() =>
      '''
VPackageInfo(
  appName: $appName,
  packageName: $packageName,
  version: $version,
  buildNumber: $buildNumber,
  buildSignature: $buildSignature,
  installerStore: $installerStore,
)''';
}
