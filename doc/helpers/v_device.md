# v_device

Import: `package:volo_flutter_utils/volo_flutter_utils.dart`

## VDevice

Platform checks and a cached summary of the current device.

The `is…` getters follow `defaultTargetPlatform`, so they are false on the
web (except [isWeb]) and tests can switch them with
`debugDefaultTargetPlatformOverride`. [info] wraps `device_info_plus` and
supports Android, iOS, macOS, Windows, Linux and the web; any other
platform gets a `VDeviceInfo` whose fields are all `'Unknown'`. In tests,
mock the plugin's method channel and call [clearCache].

```dart
if (VDevice.isMobile) {
  final info = await VDevice.info;
  info.model;     // 'Pixel 8'
  info.osVersion; // 'Android 14'
}
```

### Members

| Member | Description |
|---|---|
| `static DeviceInfoPlugin plugin` | The plugin [info] reads from; replace it in tests, then [clearCache]. |
| `static Future<VDeviceInfo> get info` | Device summary, read once from the platform and then cached. |
| `static bool get isWeb` | Whether the app runs in a browser. |
| `static bool get isAndroid` | Whether the app runs on Android (never true on the web). |
| `static bool get isIOS` | Whether the app runs on iOS (never true on the web). |
| `static bool get isMacOS` | Whether the app runs on macOS (never true on the web). |
| `static bool get isWindows` | Whether the app runs on Windows (never true on the web). |
| `static bool get isLinux` | Whether the app runs on Linux (never true on the web). |
| `static bool get isMobile` | Whether the app runs on Android or iOS. |
| `static bool get isDesktop` | Whether the app runs on macOS, Windows or Linux. |
| `static void clearCache()` | Drops the cached [info] so the next read asks the platform again. |

## VDeviceInfo

Snapshot of the current device, as read by [VDevice.info].

### Constructors

#### `VDeviceInfo`

Creates a snapshot from the given values.

| Parameter | Type | Default | Required | Description |
|---|---|---|---|---|
| `platform` | `String` |  | yes | Platform name: Android, iOS, Web, macOS, Windows, Linux or Unknown. |
| `model` | `String` |  | yes | Device model name. |
| `osVersion` | `String` |  | yes | OS name and version such as `Android 14`; `Unknown` if the platform has none. |
| `manufacturer` | `String` |  | yes | Maker such as `Apple`; `Unknown` when the platform does not report it. |
| `isPhysicalDevice` | `bool` |  | yes | Whether this is real hardware; always true on desktop, false on the web. |
| `deviceId` | `String?` |  |  | Identifier the platform exposes, or null when it has none.<br>Its meaning differs per platform (Android build id, iOS vendor id, macOS hardware UUID, Windows device id, Linux machine id) and some change on reinstall, so treat it as personal data and do not rely on it for identity. |
