# volo_flutter_utils

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A small set of utilities for mobile and desktop Flutter apps.

## What it contains

- **Validation**: `VValidator` (email, password, Korean mobile phone, URL, required, length, number, pattern); results are `VValidationResult`
- **Extensions**: `String` · `double` · `int` · `DateTime` · `TimeOfDay` · `Map`
- **Helpers**: `VDebouncer` · `VThrottler` · `VDevice` · `VPackage` · `VLog`

It does not contain date, currency or relative-time formatting, an HTTP client, or result and failure types. Apps handle those with `intl` or their own `Result` type.

## Installation

```yaml
dependencies:
  volo_flutter_utils:
    git:
      url: https://github.com/volo-uti/volo-flutter-utils.git
      ref: v0.1.0 # a release tag
```

The package is distributed through GitHub, not pub.dev: a release tag (`v<version>`, equal to `version` in `pubspec.yaml`) is the version a product depends on.

## Telling coding agents about it

Write the index once so coding agents can find the existing utilities. A `volo-flutter-utils-index` block appears in the product's `AGENTS.md`.

```bash
dart run volo_flutter_utils:agent_index
```

After upgrading the package, run the same command to refresh it. Add `--check` to the product's own checks. Each utility has a doc under the package's `doc/` folder.

## Usage

```dart
import 'package:volo_flutter_utils/volo_flutter_utils.dart';
```

### Validation

```dart
final result = VValidator.email('test@example.com');
if (result != VValidationResult.valid) {
  VValidator.errorKey(result, 'email');      // 'error.email.format'
  VValidator.errorMessage(result, 'email');  // 'Invalid email format'
}
```

Validation is pragmatic. Email and URL checks only reject obvious mistakes, and phone numbers accept only Korean mobile numbers (`010-1234-5678` or `+82 10-1234-5678`). Every empty input is `VValidationResult.empty`. `errorMessage` is English only; for other languages, translate in the app using `errorKey`.

### Extensions

```dart
'hello'.capitalize;              // 'Hello'
'14:30'.toTimeOfDay();           // TimeOfDay(hour: 14, minute: 30)
24.0.toFigmaHeight(16);          // 1.5
5.padLeft(2);                    // '05'
90.seconds;                      // Duration(seconds: 90)
DateTime(2024, 2, 10).daysInMonth; // 29
{'a': 1}.getAs<int>('a');        // 1
```

Date comparisons (`isToday`, `isThisWeek` ...) use the device's local time, and adding or subtracting a day works on calendar dates, so a day is never skipped at a daylight-saving change.

### Debounce and throttle

```dart
final debouncer = VDebouncer(const Duration(milliseconds: 300), search);
debouncer(); // runs once, 300ms after the last call
debouncer.cancel(); // cancel in dispose

final throttler = VThrottler(const Duration(milliseconds: 100), save);
throttler(); // runs at most once per 100ms
```

### Device and app info

```dart
VDevice.isMobile;                  // based on defaultTargetPlatform
final device = await VDevice.info; // device.model, device.osVersion
final app = await VPackage.info;   // app.version, app.versionString
```

`VDevice.info` supports Android, iOS, macOS, Windows, Linux and the web; on any other platform every field is `'Unknown'`. The `buildSignature` of `VPackage.info` is filled only on Android. Both cache the first value they read; clear it with `clearCache()`.

### Logging

```dart
VLog.debug('Debug message');          // printed in debug mode only
VLog.info('Info message', title: 'API');
VLog.error(exception: Exception('Error'));
```

## Supported platforms

Android · iOS · macOS · Windows · Linux

## Development

Requirements: [FVM](https://fvm.app) (the Flutter version is in `.fvmrc`) and Dart SDK 3.11.0 or newer.

```bash
dart pub global activate fvm   # install FVM
make setup                     # install Flutter, fetch dependencies, install the git hook
make check                     # gate: format, index, docs, analyze, tests
make index                     # rewrite the AGENTS.md index block and doc/
```

Tests run locally: `make check` is enforced by a `pre-push` hook that `make setup` installs when [lefthook](https://lefthook.dev/) is available. The remote workflow only publishes; it does not run `make check`. On Windows, use WSL2 and run everything, including `make setup`, inside it.

## Deployment

| Target | Trigger | Pipeline |
|--------|---------|----------|
| GitHub release (volo_flutter_utils) | `v*` tag push | `.github/workflows/release.yml` |

The workflow posts a start and a finish message (success, failure or cancelled) to Slack with a bot token (`chat.postMessage`). Set the `SLACK_BOT_TOKEN` secret and the `SLACK_CICD_CHANNEL` variable; if either is missing, the notification is skipped silently. The release uses the workflow's own `GITHUB_TOKEN` and needs no secret of yours.

## Contributing

Contributions are welcome. Read the [Contributing Guide](CONTRIBUTING.md) first; it covers setup, the `make check` gate and the pull request process. Everyone taking part follows the [Code of Conduct](CODE_OF_CONDUCT.md).

## Security

Please report vulnerabilities privately through the repository's Security tab, as described in the [Security Policy](SECURITY.md). Do not open a public issue.

## Principles

[PRINCIPLES.md](PRINCIPLES.md) explains why the repository is built this way and which tool enforces each rule.

## License

MIT. See [LICENSE](LICENSE).
