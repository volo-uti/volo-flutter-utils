# v_package

Import: `package:volo_flutter_utils/volo_flutter_utils.dart`

## VPackage

Reads the running app's name, version and build number once and caches it.

Wraps `package_info_plus`, which asks the native side on Android, iOS,
macOS, Windows and Linux; fields a platform lacks come back empty
([VPackageInfo.buildSignature] is filled on Android only). In tests, call
`PackageInfo.setMockInitialValues` and [clearCache] first.

```dart
final info = await VPackage.info;
info.version;       // '1.0.0'
info.versionString; // '1.0.0 (1)'
```

### Members

| Member | Description |
|---|---|
| `static Future<VPackageInfo> get info` | The app's package information, read once and then cached. |
| `static void clearCache()` | Drops the cached [info] so the next read asks the platform again. |

## VPackageInfo

Snapshot of the app's package metadata, as read by [VPackage.info].

### Constructors

#### `VPackageInfo`

Creates a snapshot from the given values.

| Parameter | Type | Default | Required | Description |
|---|---|---|---|---|
| `appName` | `String` |  | yes | App display name. |
| `packageName` | `String` |  | yes | Package name (bundle identifier). |
| `version` | `String` |  | yes | Version (e.g., '1.0.0'). |
| `buildNumber` | `String` |  | yes | Build number. |
| `buildSignature` | `String` |  | yes | Signing certificate hash; filled on Android only, empty elsewhere. |
| `installerStore` | `String?` |  |  | Store that installed the app (e.g. `com.android.vending`), if known. |

### Members

| Member | Description |
|---|---|
| `String get versionString` | The version and build number as `1.0.0 (1)`. |
