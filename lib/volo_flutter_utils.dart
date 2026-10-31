/// volo_flutter_utils - Flutter utility library.
///
/// Provides common utility functions and helpers.
/// Mobile/Desktop only (iOS, Android, Windows, macOS, Linux).
///
/// **Usage:**
///
/// ```dart
/// import 'package:volo_flutter_utils/volo_flutter_utils.dart';
///
/// // String Extensions
/// 'test@example.com'.isValidEmail; // true
/// 'hello'.capitalize; // 'Hello'
///
/// // DateTime Extensions
/// DateTime.now().isToday; // true
///
/// // Map Extensions
/// {'a': 1}.getAs<int>('a'); // 1
/// ```
library;

// Extensions
export 'src/extensions/datetime_extensions.dart';
export 'src/extensions/double_extensions.dart';
export 'src/extensions/int_extensions.dart';
export 'src/extensions/map_extensions.dart';
export 'src/extensions/string_extensions.dart';
export 'src/extensions/timeofday_extensions.dart';
// Helpers
export 'src/helpers/v_delay.dart';
export 'src/helpers/v_device.dart';
export 'src/helpers/v_log.dart';
export 'src/helpers/v_package.dart';
// Validators
export 'src/validators/v_validator.dart';
