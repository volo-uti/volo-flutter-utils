/// Range, padding, duration and Unix-time helpers for [int].
///
/// ```dart
/// 5.isBetween(1, 10);  // true
/// 5.padLeft(2);        // '05'
/// 90.seconds;          // Duration(seconds: 90)
/// 0.toDateTime();      // 1970-01-01 in local time
/// ```
extension VIntExtension on int {
  /// Whether this value lies in `[min, max]`, both ends included.
  ///
  /// ```dart
  /// 5.isBetween(1, 10); // true
  /// 0.isBetween(1, 10); // false
  /// ```
  bool isBetween(int min, int max) => this >= min && this <= max;

  /// Returns this value limited to `[min, max]` as an [int].
  ///
  /// Unlike `num.clamp` the result type is [int]. `min` greater than `max`
  /// throws, as `num.clamp` does.
  ///
  /// ```dart
  /// 5.clampTo(0, 10);  // 5
  /// 15.clampTo(0, 10); // 10
  /// ```
  int clampTo(int min, int max) => clamp(min, max).toInt();

  /// Pads the decimal form with leading zeros up to [width] characters.
  ///
  /// A negative number keeps its minus sign in front of the zeros and counts
  /// it toward [width].
  ///
  /// ```dart
  /// 5.padLeft(2);  // '05'
  /// 42.padLeft(4); // '0042'
  /// (-5).padLeft(3); // '-05'
  /// ```
  String padLeft(int width) {
    if (isNegative) {
      return '-${toString().substring(1).padLeft(width - 1, '0')}';
    }
    return toString().padLeft(width, '0');
  }

  /// Interprets this as a Unix timestamp in seconds and returns local time.
  ///
  /// ```dart
  /// 1704067200.toDateTime(); // 2024-01-01 00:00:00 UTC, shown in local time
  /// ```
  DateTime toDateTime() => DateTime.fromMillisecondsSinceEpoch(this * 1000);

  /// Interprets this as a Unix timestamp in milliseconds and returns local time.
  ///
  /// ```dart
  /// 1704067200000.toDateTimeMs(); // 2024-01-01 00:00:00 UTC, shown in local time
  /// ```
  DateTime toDateTimeMs() => DateTime.fromMillisecondsSinceEpoch(this);

  /// This many milliseconds as a [Duration].
  ///
  /// ```dart
  /// 500.milliseconds; // Duration(milliseconds: 500)
  /// ```
  Duration get milliseconds => Duration(milliseconds: this);

  /// This many seconds as a [Duration].
  ///
  /// ```dart
  /// 90.seconds; // Duration(seconds: 90)
  /// ```
  Duration get seconds => Duration(seconds: this);

  /// This many minutes as a [Duration].
  ///
  /// ```dart
  /// 5.minutes; // Duration(minutes: 5)
  /// ```
  Duration get minutes => Duration(minutes: this);

  /// This many hours as a [Duration].
  ///
  /// ```dart
  /// 2.hours; // Duration(hours: 2)
  /// ```
  Duration get hours => Duration(hours: this);

  /// This many 24-hour days as a [Duration].
  ///
  /// A [Duration] has no calendar, so adding it to a local [DateTime] across
  /// a daylight-saving change moves the clock time by an hour.
  ///
  /// ```dart
  /// 7.days; // Duration(days: 7)
  /// ```
  Duration get days => Duration(days: this);
}
