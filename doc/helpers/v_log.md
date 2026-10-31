# v_log

Import: `package:volo_flutter_utils/volo_flutter_utils.dart`

## VLog

Prints tagged log lines with the caller's file location.

Output goes through `debugPrint`. [debug] prints in debug mode only;
[info], [warn] and [error] also print in release builds, so keep secrets
out of them. Nothing is sent anywhere else.

```dart
VLog.debug('User logged in');
VLog.info('Request sent', title: 'API');
VLog.warn('Cache expired', showTime: true);
VLog.error(exception: e, message: 'Upload failed');
```

### Members

| Member | Description |
|---|---|
| `static void debug(Object message, {String title = '', bool showTime = false, bool showPath = true})` | Prints a debug line, only in [kDebugMode].<br>[title] prefixes the message; [showTime] adds a timestamp and [showPath] (default true) the caller's location. |
| `static void info(Object message, {String title = '', bool showTime = false, bool showPath = true})` | Prints an info line in every build mode. |
| `static void warn(Object message, {String title = '', bool showTime = false, bool showPath = true})` | Prints a warning line in every build mode. |
| `static void error({Object? exception, String title = '', String? message, bool showTime = false, bool showPath = true})` | Prints an error line in every build mode.<br>Prints [message] if given, else `exception.toString()`, else `Unknown error`. |
