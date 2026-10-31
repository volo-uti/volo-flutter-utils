import 'package:clock/clock.dart';

/// Calendar comparisons and day, month boundaries for [DateTime].
///
/// Every "is today / this week" check compares the calendar fields of the
/// receiver with the device's local `clock.now()`, so call them on local
/// values. Date math builds new values from calendar fields, never by adding a
/// 24-hour [Duration], so daylight-saving shifts cannot skip or repeat a day.
///
/// ```dart
/// final d = DateTime(2024, 2, 10, 15, 30);
/// d.startOfDay;   // 2024-02-10 00:00:00
/// d.daysInMonth;  // 29
/// d.isWeekend;    // true (Saturday)
/// ```
extension VDateTimeExtension on DateTime {
  // ============================================================
  // Comparison
  // ============================================================

  /// Checks whether this date is today.
  ///
  /// ```dart
  /// DateTime.now().isToday; // true
  /// DateTime.now().subtract(Duration(days: 1)).isToday; // false
  /// ```
  bool get isToday {
    final now = clock.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Checks whether this date is tomorrow.
  ///
  /// ```dart
  /// DateTime.now().add(Duration(days: 1)).isTomorrow; // true
  /// ```
  bool get isTomorrow {
    final now = clock.now();
    return isSameDay(DateTime(now.year, now.month, now.day + 1));
  }

  /// Checks whether this date is yesterday.
  ///
  /// ```dart
  /// DateTime.now().subtract(Duration(days: 1)).isYesterday; // true
  /// ```
  bool get isYesterday {
    final now = clock.now();
    return isSameDay(DateTime(now.year, now.month, now.day - 1));
  }

  /// Checks whether this date is within the current week (Monday to Sunday).
  ///
  /// ```dart
  /// DateTime.now().isThisWeek; // true
  /// ```
  bool get isThisWeek {
    final now = clock.now();
    final monday = DateTime(now.year, now.month, now.day - (now.weekday - 1));
    final nextMonday = DateTime(monday.year, monday.month, monday.day + 7);
    final date = startOfDay;
    return !date.isBefore(monday) && date.isBefore(nextMonday);
  }

  /// Checks whether this date is within the current month.
  ///
  /// ```dart
  /// DateTime.now().isThisMonth; // true
  /// ```
  bool get isThisMonth {
    final now = clock.now();
    return year == now.year && month == now.month;
  }

  /// Checks whether this date is within the current year.
  ///
  /// ```dart
  /// DateTime.now().isThisYear; // true
  /// ```
  bool get isThisYear => year == clock.now().year;

  /// Checks whether this date is a weekend.
  ///
  /// ```dart
  /// DateTime(2024, 12, 28).isWeekend; // true (Saturday)
  /// ```
  bool get isWeekend =>
      weekday == DateTime.saturday || weekday == DateTime.sunday;

  /// Checks whether this date is a weekday.
  ///
  /// ```dart
  /// DateTime(2024, 12, 27).isWeekday; // true (Friday)
  /// ```
  bool get isWeekday => !isWeekend;

  // ============================================================
  // Manipulation
  // ============================================================

  /// Returns the start of the day (00:00:00).
  ///
  /// In a zone whose daylight-saving change skips midnight (such as Santiago),
  /// that day starts at 01:00, the first moment that exists.
  ///
  /// ```dart
  /// DateTime.now().startOfDay; // 2024-12-28 00:00:00
  /// ```
  DateTime get startOfDay =>
      copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);

  /// Returns the last millisecond of the day (23:59:59.999).
  ///
  /// ```dart
  /// DateTime.now().endOfDay; // 2024-12-28 23:59:59.999
  /// ```
  DateTime get endOfDay => copyWith(
    hour: 23,
    minute: 59,
    second: 59,
    millisecond: 999,
    microsecond: 0,
  );

  /// Returns the start of the month.
  ///
  /// ```dart
  /// DateTime.now().startOfMonth; // 2024-12-01 00:00:00
  /// ```
  DateTime get startOfMonth => copyWith(day: 1).startOfDay;

  /// Returns the end of the month.
  ///
  /// ```dart
  /// DateTime.now().endOfMonth; // 2024-12-31 23:59:59.999
  /// ```
  DateTime get endOfMonth => copyWith(day: daysInMonth).endOfDay;

  /// Returns the number of days in the month.
  ///
  /// ```dart
  /// DateTime(2024, 2, 1).daysInMonth; // 29 (leap year)
  /// DateTime(2023, 2, 1).daysInMonth; // 28
  /// ```
  int get daysInMonth => DateTime.utc(year, month + 1, 0).day;

  /// Compares whether two dates are the same day (ignoring time).
  ///
  /// ```dart
  /// DateTime(2024, 12, 28, 10, 30).isSameDay(DateTime(2024, 12, 28, 15, 45)); // true
  /// ```
  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  /// Copies the date with modified fields, keeping the local or UTC kind.
  ///
  /// ```dart
  /// DateTime.now().copyWith(hour: 0, minute: 0); // midnight today
  /// ```
  DateTime copyWith({
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    int? second,
    int? millisecond,
    int? microsecond,
  }) {
    final args = [
      year ?? this.year,
      month ?? this.month,
      day ?? this.day,
      hour ?? this.hour,
      minute ?? this.minute,
      second ?? this.second,
      millisecond ?? this.millisecond,
      microsecond ?? this.microsecond,
    ];
    return isUtc
        ? DateTime.utc(
            args[0],
            args[1],
            args[2],
            args[3],
            args[4],
            args[5],
            args[6],
            args[7],
          )
        : DateTime(
            args[0],
            args[1],
            args[2],
            args[3],
            args[4],
            args[5],
            args[6],
            args[7],
          );
  }
}
