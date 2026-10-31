import 'package:flutter/foundation.dart';

/// Prints tagged log lines with the caller's file location.
///
/// Output goes through `debugPrint`. [debug] prints in debug mode only;
/// [info], [warn] and [error] also print in release builds, so keep secrets
/// out of them. Nothing is sent anywhere else.
///
/// ```dart
/// VLog.debug('User logged in');
/// VLog.info('Request sent', title: 'API');
/// VLog.warn('Cache expired', showTime: true);
/// VLog.error(exception: e, message: 'Upload failed');
/// ```
class VLog {
  VLog._();

  /// Prints a debug line, only in [kDebugMode].
  ///
  /// [title] prefixes the message; [showTime] adds a timestamp and [showPath]
  /// (default true) the caller's location.
  static void debug(
    Object message, {
    String title = '',
    bool showTime = false,
    bool showPath = true,
  }) {
    if (kDebugMode) {
      _log('DEBUG', title, message, showTime, showPath);
    }
  }

  /// Prints an info line in every build mode.
  static void info(
    Object message, {
    String title = '',
    bool showTime = false,
    bool showPath = true,
  }) {
    _log('INFO', title, message, showTime, showPath);
  }

  /// Prints a warning line in every build mode.
  static void warn(
    Object message, {
    String title = '',
    bool showTime = false,
    bool showPath = true,
  }) {
    _log('WARN', title, message, showTime, showPath);
  }

  /// Prints an error line in every build mode.
  ///
  /// Prints [message] if given, else `exception.toString()`, else
  /// `Unknown error`.
  static void error({
    Object? exception,
    String title = '',
    String? message,
    bool showTime = false,
    bool showPath = true,
  }) {
    final errorMessage = message ?? exception?.toString() ?? 'Unknown error';
    _log('ERROR', title, errorMessage, showTime, showPath);
  }

  static void _log(
    String prefix,
    String title,
    Object message,
    bool showTime,
    bool showPath,
  ) {
    var date = '';
    if (showTime) {
      date = '[${_timestamp(DateTime.now())}] ';
    }

    var path = '';
    if (showPath) {
      path = '${_extractCallPath()}\n';
    }

    final log = title.isEmpty ? message : '$title >>> $message';

    debugPrint('$path$date[$prefix] $log\n');
  }

  /// Extracts the call location from a StackTrace.
  static String _extractCallPath() {
    try {
      final stackTrace = StackTrace.current.toString();
      final lines = stackTrace.split('\n');

      // Skip internal VLog calls and find the actual call location
      for (final line in lines) {
        if (!line.contains('v_log.dart') &&
            !line.contains('VLog') &&
            line.contains('(')) {
          final start = line.indexOf('(');
          final end = line.indexOf(')');
          if (start != -1 && end != -1 && end > start) {
            return line.substring(start + 1, end).trim();
          }
        }
      }
      return '';
    } catch (_) {
      return '';
    }
  }

  /// Formats as `yyyy-MM-dd HH:mm:ss.SSS`.
  static String _timestamp(DateTime t) {
    String p(int n, [int w = 2]) => n.toString().padLeft(w, '0');
    return '${p(t.year, 4)}-${p(t.month)}-${p(t.day)} '
        '${p(t.hour)}:${p(t.minute)}:${p(t.second)}.${p(t.millisecond, 3)}';
  }
}
