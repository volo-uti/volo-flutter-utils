import 'package:clock/clock.dart';
import 'package:flutter/material.dart';

/// Comparison and midnight-wrapping arithmetic for [TimeOfDay].
///
/// ```dart
/// const t = TimeOfDay(hour: 23, minute: 30);
/// t.add(const Duration(hours: 2)); // 01:30 the next day, as a TimeOfDay
/// t.toMinutes();                   // 1410
/// t.toDateTime(date: DateTime(2024, 1, 1)); // 2024-01-01 23:30
/// ```
extension VTimeOfDayExtension on TimeOfDay {
  /// Combines this time with [date] (default: today) into a local [DateTime].
  ///
  /// Seconds and smaller units are zero. Today comes from `clock.now()`, so
  /// tests can override it with `withClock`. A time skipped by a daylight-saving
  /// change moves forward, as `DateTime` does: 02:30 on a spring-forward day
  /// gives 03:30.
  ///
  /// ```dart
  /// TimeOfDay(hour: 14, minute: 30).toDateTime(); // Today at 14:30
  /// TimeOfDay(hour: 9, minute: 0).toDateTime(date: DateTime(2024, 1, 1)); // 2024-01-01 09:00
  /// ```
  DateTime toDateTime({DateTime? date}) {
    final d = date ?? clock.now();
    return DateTime(d.year, d.month, d.day, hour, minute);
  }

  /// Whether this time is earlier in the day than [other].
  ///
  /// ```dart
  /// TimeOfDay(hour: 9, minute: 0).isBefore(TimeOfDay(hour: 10, minute: 0)); // true
  /// TimeOfDay(hour: 10, minute: 30).isBefore(TimeOfDay(hour: 10, minute: 0)); // false
  /// ```
  bool isBefore(TimeOfDay other) =>
      hour < other.hour || (hour == other.hour && minute < other.minute);

  /// Whether this time is later in the day than [other].
  ///
  /// ```dart
  /// TimeOfDay(hour: 10, minute: 0).isAfter(TimeOfDay(hour: 9, minute: 0)); // true
  /// TimeOfDay(hour: 10, minute: 0).isAfter(TimeOfDay(hour: 10, minute: 30)); // false
  /// ```
  bool isAfter(TimeOfDay other) =>
      hour > other.hour || (hour == other.hour && minute > other.minute);

  /// Minutes since midnight, from 0 to 1439.
  ///
  /// ```dart
  /// TimeOfDay(hour: 1, minute: 30).toMinutes(); // 90
  /// TimeOfDay(hour: 0, minute: 0).toMinutes(); // 0
  /// TimeOfDay(hour: 23, minute: 59).toMinutes(); // 1439
  /// ```
  int toMinutes() => hour * 60 + minute;

  /// Returns this time moved forward by [duration], wrapping past midnight.
  ///
  /// Only whole minutes count; seconds of [duration] are dropped.
  ///
  /// ```dart
  /// TimeOfDay(hour: 10, minute: 30).add(Duration(hours: 2)); // 12:30
  /// TimeOfDay(hour: 23, minute: 30).add(Duration(hours: 2)); // 01:30
  /// ```
  TimeOfDay add(Duration duration) {
    final totalMinutes = (toMinutes() + duration.inMinutes) % (24 * 60);
    return TimeOfDay(hour: totalMinutes ~/ 60, minute: totalMinutes % 60);
  }

  /// Returns this time moved back by [duration], wrapping before midnight.
  ///
  /// Only whole minutes count; seconds of [duration] are dropped.
  ///
  /// ```dart
  /// TimeOfDay(hour: 10, minute: 30).subtract(Duration(hours: 2)); // 08:30
  /// TimeOfDay(hour: 1, minute: 30).subtract(Duration(hours: 2)); // 23:30
  /// ```
  TimeOfDay subtract(Duration duration) {
    final totalMinutes = (toMinutes() - duration.inMinutes) % (24 * 60);
    return TimeOfDay(hour: totalMinutes ~/ 60, minute: totalMinutes % 60);
  }

  /// Minutes from [other] to this time, negative when this is earlier.
  ///
  /// Does not wrap: 00:10 minus 23:50 is -1420.
  ///
  /// ```dart
  /// TimeOfDay(hour: 10, minute: 30).difference(TimeOfDay(hour: 9, minute: 0)); // 90
  /// TimeOfDay(hour: 9, minute: 0).difference(TimeOfDay(hour: 10, minute: 30)); // -90
  /// ```
  int difference(TimeOfDay other) => toMinutes() - other.toMinutes();
}
